//
//  EditorTextStorage.swift
//  
//
//  Created by Matthew Davidson on 5/12/19.
//

import Foundation
import EditorCore
import Cocoa

public class EditorTextStorage: NSTextStorage {

    private var storage: NSMutableAttributedString

    private var lineRanges: [NSRange]

    private var lineStartLocs: [Int] {
        return lineRanges.map { $0.location }
    }

    private var nContentLines: Int {
        return lineRanges.count - (lineRanges.last!.length == 0 ? 1 : 0)
    }

    private var states = [LineState?]()

    private var tokenizedLines = [TokenizedLine?]()

    private var matchTokens = [[Token]]()

    private var parser: Parser

    private var grammar: Grammar

    private var theme: Theme

    var lastProcessedRange = NSRange(location: 0, length: 0)

    private var _isProcessingEditing = false

    public var isProcessingEditing: Bool {
        _isProcessingEditing
    }

    public var shouldDebug = false

    var selectionLines = Set<Int>()

    init(parser: Parser, baseGrammar: Grammar, theme: Theme) {
        storage = NSMutableAttributedString(string: "", attributes: nil)
        self.lineRanges = [NSRange(location: 0, length: 0)]
        self.parser = parser
        self.grammar = baseGrammar
        self.theme = theme
        super.init()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("\(#function) is not supported")
    }

    required init?(pasteboardPropertyList propertyList: AnyObject, ofType type: String) {
        fatalError("\(#function) is not supported")
    }

    required init?(pasteboardPropertyList propertyList: Any, ofType type: PasteboardType) {
        fatalError("\(#function) is not supported")
    }

    // MARK: - Required NSTextStorage methods
    override public var string: String {
        return storage.string
    }

    override public func attributes(at location: Int,
                                    effectiveRange range: NSRangePointer?) -> [NSAttributedString.Key: Any] {
        return storage.attributes(at: location, effectiveRange: range)
    }

    override public func replaceCharacters(in range: NSRange, with str: String) {
        beginEditing()

        // First update the storage
        storage.replaceCharacters(in: range, with: str)

        // Then update the line ranges
        updateLineRanges(forCharactersReplacedInRange: range, with: str)

        // Check the line ranges in testing
//        checkLineRanges()

        edited(.editedCharacters, range: range, changeInLength: (str as NSString).length - range.length)
        endEditing()
    }

    private func updateLineRanges(forCharactersReplacedInRange range: NSRange, with str: String) {
        // First remove the line start locations in the affected range
        var line = 0
        if range.length != 0 {
            var foundFirstMatch = false
            while line < lineRanges.count {
                if range.contains(lineRanges[line].location - 1) {
                    foundFirstMatch = true
                    lineRanges.remove(at: line)
                } else if !foundFirstMatch {
                    line += 1
                } else {
                    break
                }
            }
        }

        // Find the line index for where to insert any new line start locations
        line = 0
        while line < lineRanges.count && range.location > lineRanges[line].location - 1 {
            line += 1
        }

        // Find the new line start locations, adding the offset and 1 to get the location of the next line.
        let newLineLocs = str.utf16.indices.filter { str[$0] == "\n" }.map {
            $0.utf16Offset(in: str) + 1 + range.location }

        // Create new line ranges with 0 length.
        let newLineRanges = newLineLocs.map { NSRange(location: $0, length: 0) }
        lineRanges.insert(contentsOf: newLineRanges, at: line)

        // Shift the start locations after inserted ranges.
        for i in line+newLineRanges.count..<lineRanges.count {
            lineRanges[i].location += str.utf16.count - range.length
        }

        // Update lengths of new ranges and the one before (as it may have changed)
        for i in max(line-1, 0)..<min(lineRanges.count - 1, line+newLineRanges.count) {
            lineRanges[i].length = lineRanges[i + 1].location - lineRanges[i].location
        }

        // If the last line range is a new line range, we set the length based on the text storage.
        if newLineRanges.count + line == lineRanges.count {
            lineRanges[lineRanges.count - 1].length = storage.length - lineRanges[lineRanges.count - 1].location
        }
    }

    func checkLineRanges() {
        assert(!lineRanges.isEmpty)

        var i = 0
        while i < lineRanges.count-2 {
            assert(lineRanges[i].upperBound == lineRanges[i+1].location)
            i += 1
        }

        if let lastNewLine = storage.string.lastIndex(of: "\n")?.utf16Offset(in: storage.string) {
            assert(lineRanges.last!.length == storage.length - (lastNewLine + 1))
        } else {
            assert(lineRanges.last?.length == storage.length)
        }
    }

    override public func setAttributes(_ attrs: [NSAttributedString.Key: Any]?, range: NSRange) {
        beginEditing()
        storage.setAttributes(attrs, range: range)
        edited(.editedAttributes, range: range, changeInLength: 0)
        endEditing()
    }

    private func getEditedLines(lineStartLocs: [Int], editedRange: NSRange) -> (Int, Int) {
        var first = 0
        while first < lineStartLocs.count - 1 {
            if editedRange.location < lineStartLocs[first+1] {
                break
            }
            first += 1
        }

        // We figure out the last line that was edited.
        var last = first
        while last < lineStartLocs.count - 1 {
            if editedRange.upperBound <= lineStartLocs[last+1] {
                break
            }
            last += 1
        }

        return (first, last)
    }

    ///
    /// Gets the last line that need to be processed at a minimum given the last edited line.
    ///
    /// - Parameter lastEditedLine: The index of the last edited line.
    /// - Parameter editedRange: The range of characters which have been edited.
    /// - Returns: The last line that needs to be processed at a minimum.
    ///
    private func getLastProcessingLine(lastEditedLine: Int, editedRange: NSRange, text: String) -> Int {
        // We add 1 to the last edited line if a newline was the last character of the
        // edit to extend the edited range to enforce checking the new line as well.
        // Take the last edited utf16 character in the range. Since NSRanges are based on utf16 characters.
        let u16Last = text.utf16.index(text.utf16.startIndex, offsetBy: max(editedRange.upperBound - 1, 0))
        // Find it's unicode position, and see if it is a newline
        if let uLast = u16Last.samePosition(in: text.unicodeScalars) {
            if text[uLast] == "\n" {
                return lastEditedLine + 1
            }
        }

        return lastEditedLine
    }

    ///
    /// Modifies the length of the states and tokenized lines array based on the first edited
    /// line to prepare for the processing based of the previous states.
    ///
    /// - Parameter firstEditedLine: The first line that was edited.
    /// - Parameter changeInLines: The number of lines added or deleted.
    ///
    private func adjustCache(firstEditedLine: Int, changeInLines: Int) {
        if changeInLines < 0 {
            for _ in 0..<abs(changeInLines) {
                states.remove(at: firstEditedLine + 1)
                tokenizedLines.remove(at: firstEditedLine)
                matchTokens.remove(at: firstEditedLine)
            }
        } else {
            for _ in 0..<abs(changeInLines) {
                states.insert(nil, at: firstEditedLine + 1)
                tokenizedLines.insert(nil, at: firstEditedLine)
                matchTokens.insert([], at: firstEditedLine)
            }
        }
    }

    public func getLocationLine(_ loc: Int) -> Int {
        var line = 0
        while line < lineRanges.count {
            if loc < lineRanges[line].upperBound {
                break
            }
            line += 1
        }

        return min(line, lineRanges.count - 1)
    }

    public func getLine(_ i: Int) -> String {
        return (string as NSString).substring(with: lineRanges[i])
    }

    public func getLocationOnLine(_ loc: Int) -> Int {
        let line = getLocationLine(loc)

        return loc - lineRanges[line].location
    }

    public func getLineRange(_ line: Int) -> NSRange? {
        guard line >= 0 && line < lineRanges.count else {
            return nil
        }
        return lineRanges[line]
    }

    private func getCursorLine(lineRanges: [NSRange], editedRange: NSRange) -> Int {
        // We figure out line the cursor will be on
        var cursorLine = 0
        while cursorLine < lineRanges.count {
            if editedRange.upperBound < lineRanges[cursorLine].upperBound {
                break
            }
            cursorLine += 1
        }

        return cursorLine
    }

    ///
    /// Processes syntax highlighting on the minimum range possible.
    ///
    /// - Parameter editedRange: The range of the edit, if known. If the edited range is  provided
    ///     the syntax highlighting will be done by processing the least amount of the document as possible
    ///     using the pevious state of the document.
    /// - Returns: The processed range: the range of the string that was processed and attributes were applied.
    ///
    func processSyntaxHighlighting(editedRange: NSRange) -> NSRange {
        // Return if empty
        if string.isEmpty {
            matchTokens = []
            tokenizedLines = []
            states.removeAll()
            return fullRange
        }

        // Get the number of content lines.
        let nContentLines = self.nContentLines

        // Default the processing lines to the entire document.
        var processingLines = (first: 0, last: nContentLines-1)

        // Calculate the change in number of lines and adjust the states array
        let change = nContentLines - states.count + 1

        // If we have cached states for the lines we do not need to process the entire string,
        // we can simply on process the lines that have changed or lines afterwards
        // that have been affected by the change.
        if !states.isEmpty && !tokenizedLines.isEmpty {
            processingLines = getEditedLines(lineStartLocs: lineStartLocs, editedRange: editedRange)
            processingLines.last = getLastProcessingLine(lastEditedLine: processingLines.last,
                                                         editedRange: editedRange,
                                                         text: storage.string)
            processingLines.last = min(processingLines.last, nContentLines-1)
            adjustCache(firstEditedLine: processingLines.first, changeInLines: change)
        } else {
            // Either both caches are empty or the cache is in an inconsistent state, either way, init both
            tokenizedLines = .init(repeating: nil, count: nContentLines)
            matchTokens = .init(repeating: [], count: nContentLines)
            states = [grammar.createFirstLineState(theme: theme)]
        }

        var processingLine = processingLines.first
        var tokenizedLines = [TokenizedLine]()
        while processingLine <= processingLines.last {
            // Get the state
            guard let state = states[processingLine] else {
                fatalError("State unexpectedly nil for line \(processingLine)")
            }

            // Tokenize the line
            let line = (storage.string as NSString).substring(with: lineRanges[processingLine])
            let result = parser.tokenize(line: line, state: state, withTheme: theme)
            tokenizedLines.append(result.tokenizedLine)

            self.tokenizedLines[processingLine] = result.tokenizedLine
            self.matchTokens[processingLine] = result.matchTokens

            // See if the state (for the next line) was previously cached
            if processingLine + 1 < states.count {
                // Check if we're not on the last line of the text, but on the
                // last line of the processing lines and the state is different to the cache.
                // If so we need to keep caching by extending the processing lines.
                if processingLine < nContentLines - 1 &&
                    processingLine == processingLines.last &&
                    result.state != states[processingLine + 1] {
                    processingLines.last += 1
                }
                states[processingLine + 1] = result.state
            } else {
                // Cache the line
                states.append(result.state)
            }

            // Process next line
            processingLine += 1
        }

        // Update the line of the cursor.
        let cursorLine = getCursorLine(lineRanges: lineRanges, editedRange: editedRange)
        if cursorLine < nContentLines {
            selectionLines.removeAll()
            selectionLines.insert(cursorLine)
        }

        let startOfProcessing = lineRanges[processingLines.first].location
        let processingLength = lineRanges[processingLines.last].upperBound - startOfProcessing

        tokenizedLines.enumerated().forEach {
            $1.applyTheme(storage, at: lineRanges[$0 + processingLines.first].location,
                          inSelectionScope: $0 + processingLines.first == cursorLine)
        }

        let processedRange = NSRange(location: startOfProcessing, length: processingLength)

        // Important for fixing fonts where the font does not contain the glyph in the text, e.g. emojis.
        fixAttributes(in: processedRange)

        debug("Lines processed: \(processingLines.first) to \(processingLines.last)")

        guard !self.tokenizedLines.contains(where: {$0==nil}) && self.tokenizedLines.count == nContentLines else {
            fatalError("Failed to cache tokenized lines correctly")
        }

        return processedRange
    }

    public override func processEditing() {
        let editedRange = self.editedRange
        _isProcessingEditing = true
        defer {
            _isProcessingEditing = false
        }

        // Replicate super.processEditing() without the fixAttributes as we will do that later
        NotificationCenter.default.post(name: NSTextStorage.willProcessEditingNotification, object: self)
        NotificationCenter.default.post(name: NSTextStorage.didProcessEditingNotification, object: self)
        layoutManagers.forEach { manager in
            manager.processEditing(for: self,
                                   edited: editedMask,
                                   range: editedRange,
                                   changeInLength: changeInLength, invalidatedRange: editedRange)
        }

        if !editedMask.contains(.editedCharacters) {
            return
        }

        let range = processSyntaxHighlighting(editedRange: editedRange)
        debug("editedRange: \(editedRange)")
        debug("Range processed: \(range)")
        debug()

        self.lastProcessedRange = range

        layoutManagers.forEach { manager in
            manager.processEditing(for: self,
                                   edited: .editedAttributes,
                                   range: range,
                                   changeInLength: 0,
                                   invalidatedRange: range)
        }
    }

    public func replace(parser: Parser, baseGrammar: Grammar, theme: Theme) {
        self.parser = parser
        self.grammar = baseGrammar
        self.theme = theme
        states = []
        edited(.editedCharacters, range: fullRange, changeInLength: 0)
    }

    /// - Returns: The ranges that had changed
    public func updateSelectedRanges(_ selectedRanges: [NSRange]) -> NSRange {
        // Return if empty
        if string.isEmpty {
            return NSRange(location: NSNotFound, length: 0)
        }

        // Find the lines of selection
        var selectionLines = Set<Int>()
        for range in selectedRanges {
            let (i, j) = getEditedLines(lineStartLocs: self.lineStartLocs, editedRange: range)
            for x in i...j {
                selectionLines.insert(x)
            }
        }

        // Find the new and removed lines of selection
        let newLines = selectionLines.subtracting(self.selectionLines)
        let removedLines = self.selectionLines.subtracting(selectionLines)

        // Update selectionLines
        self.selectionLines = selectionLines

        // Update the selected and unselected lines
        var lineLoc = 0
        var rangesChanged = [NSRange]()
        for (i, tokenizedLine) in tokenizedLines.enumerated() {
            guard let tokenizedLine = tokenizedLine else {
                print("Warning: Unexpectedly found nil tokenized line at index \(i) in updateSelectedRanges")
                continue
            }

            if newLines.contains(i) {
                tokenizedLine.applyTheme(storage, at: lineLoc, inSelectionScope: true, applyBaseAttributes: false)
                rangesChanged.append(NSRange(location: lineLoc, length: tokenizedLine.length))
            }
            if removedLines.contains(i) {
                tokenizedLine.applyTheme(storage, at: lineLoc, inSelectionScope: false, applyBaseAttributes: false)
                rangesChanged.append(NSRange(location: lineLoc, length: tokenizedLine.length))
            }

            lineLoc += tokenizedLine.length
        }

        if !rangesChanged.isEmpty {
            let first = rangesChanged.removeFirst()
            let rangeChanged = rangesChanged.reduce(first, {
                return $0.union($1)
            })

            layoutManagers.forEach { manager in
                manager.processEditing(for: self,
                                       edited: .editedAttributes,
                                       range: NSRange(location: rangeChanged.upperBound, length: 0),
                                       changeInLength: 0,
                                       invalidatedRange: rangeChanged)
            }

            return rangeChanged
        } else {
            return NSRange(location: NSNotFound, length: 0)
        }
    }

    public func getTokens(forScope scope: String) -> [(String, NSRange)] {
        var res = [(String, NSRange)]()
        let str = (storage.string as NSString)
        for (i, matchTokens) in self.matchTokens.enumerated() {
            let ranges = matchTokens.filter({ $0.scopeNames.last?.rawValue == scope })
                .map({ $0.range.shifted(by: lineRanges[i].location) })

            res += zip(ranges.map { str.substring(with: $0) }, ranges)
        }
        return res
    }

    private func debug(_ str: String = "") {
        if shouldDebug {
            print(str)
        }
    }
}
