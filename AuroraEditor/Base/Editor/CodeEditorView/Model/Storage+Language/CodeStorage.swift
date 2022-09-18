//
//  CodeStorage.swift
//
//  Created by Manuel M T Chakravarty on 09/01/2021.
//
//  This file contains `NSTextStorage` extensions for code editing.

import AppKit

// MARK: -
// MARK: `NSTextStorage` subclass

// `NSTextStorage` is a class cluster; hence, we realise our subclass by decorating an embeded vanilla text storage.
class CodeStorage: NSTextStorage {

    let textStorage: NSTextStorage = NSTextStorage()

    var theme: Theme

    override var string: String { textStorage.string }

    init(theme: Theme) {
        self.theme = theme
        super.init()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    required init?(pasteboardPropertyList propertyList: Any, ofType type: NSPasteboard.PasteboardType) {
        fatalError("init(pasteboardPropertyList:ofType:) has not been implemented")
    }

    override func attributes(at location: Int, effectiveRange range: NSRangePointer?) -> [NSAttributedString.Key: Any] {
        var attributes = textStorage.attributes(at: location, effectiveRange: range)
        var foregroundColour = theme.textColour

        // Translate attributes indicating text highlighting to the foreground colour determined by the current theme.
        if attributes[.comment] != nil {
            foregroundColour = theme.commentColour
        } else if let tokenAttr = attributes[.token] as? TokenAttribute<LanguageConfiguration.Token> {
            switch tokenAttr.token {
            case .string:     foregroundColour = theme.stringColour
            case .character:  foregroundColour = theme.characterColour
            case .number:     foregroundColour = theme.numberColour
            case .identifier: foregroundColour = theme.identifierColour
            case .keyword:    foregroundColour = theme.keywordColour
            default: ()
            }
        }

        attributes[.foregroundColor] = foregroundColour
        return attributes
    }

    // Extended to handle auto-deletion of adjcent matching brackets
    override func replaceCharacters(in range: NSRange, with str: String) {

        beginEditing()

        // We are deleting one character => check whether it is a one-character
        // bracket and if so also delete its matching bracket if it is directly adjascent
        if range.length == 1 && str.isEmpty,
           let token = tokenAttribute(at: range.location),
           let language = (delegate as? CodeStorageDelegate)?.language {

            let isOpen = token.token.isOpenBracket,
                isBracket = isOpen || token.token.isCloseBracket,
                isSafe = (isOpen && range.location + 1 < string.utf16.count) || range.location > 0,
                offset = isOpen ? 1 : -1
            if isBracket && isSafe && language.lexeme(of: token.token)?.count == 1 &&
                tokenAttribute(at: range.location + offset)?.token == token.token.matchingBracket {

                let extendedRange = NSRange(location: isOpen ? range.location : range.location - 1, length: 2)
                textStorage.replaceCharacters(in: extendedRange, with: "")
                edited(.editedCharacters, range: extendedRange, changeInLength: -2)
                setInsertionPointAfterDeletion(of: extendedRange)

            } else {

                textStorage.replaceCharacters(in: range, with: str)
                edited(.editedCharacters, range: range, changeInLength: (str as NSString).length - range.length)

            }

        } else {

            textStorage.replaceCharacters(in: range, with: str)
            edited(.editedCharacters, range: range, changeInLength: (str as NSString).length - range.length)

        }
        endEditing()
    }

    override func setAttributes(_ attrs: [NSAttributedString.Key: Any]?, range: NSRange) {
        beginEditing()
        textStorage.setAttributes(attrs, range: range)
        edited(.editedAttributes, range: range, changeInLength: 0)
        endEditing()
    }
}

// MARK: -
// MARK: Custom handling of the insertion point

extension CodeStorage {

    /// Insert the given string, such that it safe in an ongoing insertion cycle and does leave the cursor (insertion
    /// point) in place if the insertion is at the location of the insertion point.
    ///
    func cursorInsert(string: String, at index: Int) {

        Dispatch.DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + DispatchTimeInterval.milliseconds(10)) {
            // Collect the text views, where we insert at the insertion point
            var affectedTextViews: [NSTextView] = []
            for layoutManager in self.layoutManagers {
                for textContainer in layoutManager.textContainers {

                    if let textView = textContainer.textView,
                       textView.selectedRange() == NSRange(location: index, length: 0) {
                        affectedTextViews.append(textView)
                    }
                }
            }

            self.replaceCharacters(in: NSRange(location: index, length: 0), with: string)

            // Reset the insertion point to the original (pre-insertion) position
            // (as it will move after the inserted text on macOS otherwise)
            for textView in affectedTextViews { textView.setSelectedRange(NSRange(location: index, length: 0)) }
        }
    }

    /// Set the insertion point of all attached text views, where the selection intersects the given range, to the start
    /// of the range. This is safe in an editing cycle, as the selection setting is deferred until completion.
    ///
    /// - Parameter range: The deleted chracter range.
    ///
    func setInsertionPointAfterDeletion(of range: NSRange) {

        for layoutManager in self.layoutManagers {
            for textContainer in layoutManager.textContainers {

                if let codeContainer = textContainer as? CodeContainer,
                   let textView = codeContainer.textView,
                   NSIntersectionRange(textView.selectedRange, range).length != 0 {
                    Dispatch.DispatchQueue.main.async {
                        textView.selectedRange = NSRange(location: range.location, length: 0)
                    }
                }
            }
        }
    }
}

// MARK: -
// MARK: Token attributes

extension CodeStorage {

    /// Determine the token attribute value at the given character index. This will be `.tokenBody` if the indexed
    /// character is a body character (i.e., second or later) of a token lexeme.
    ///
    func tokenAttribute(at location: Int) -> TokenAttribute<LanguageConfiguration.Token>? {

        // Use the concrete text storage here as `CodeStorage.attributes(_:at:effectiveRange:)` does attribute synthesis
        // that we don't want here.
        return textStorage.attribute(.token, at: location, effectiveRange: nil)
        as? TokenAttribute<LanguageConfiguration.Token>
    }

    /// Determine the type and range of the token to which the character at the given index belongs, if it is part of a
    /// token at all.
    ///
    func token(at location: Int) -> (type: LanguageConfiguration.Token, range: NSRange)? {

        func determineTokenLength(type: LanguageConfiguration.Token, start: Int)
        -> (type: LanguageConfiguration.Token, range: NSRange)? {
            var idx = location + 1
            while idx < length, tokenAttribute(at: idx)?.isHead == false { idx += 1 }
            return (type: type, range: NSRange(location: start, length: idx - start))
        }

        var idx = location
        while idx >= 0 && idx < length {

            if let attribute = tokenAttribute(at: idx) {

                if !attribute.isHead { idx -= 1 }   // still looking for the first character of the lexeme
                else {                              // we found the first character of a token

                    return determineTokenLength(type: attribute.token, start: idx)

                }
            } else { return nil }   // no token (head) attribute => character is not part of a token lexeme
        }
        return nil      // this shouldn't happen...
    }

    /// Executes the specified closure for each token in the given range.
    ///
    /// - Parameters:
    ///   - enumerationRange: The range overwhich tokens are enumerated.
    ///   - reverseEnumeration: Pass `true` if the enumeration should proceed in reverse.
    ///   - block: The closure to apply to the token types and ranges found.
    ///
    /// See `NSAttributedString.enumerateAttribute(_:in:options:using:)` for further details of the parameters.
    ///
    func enumerateTokens(in enumerationRange: NSRange,
                         reverse reverseEnumeration: Bool = false,
                         using block: (LanguageConfiguration.Token, NSRange, UnsafeMutablePointer<ObjCBool>) -> Void) {
        let opts: NSAttributedString.EnumerationOptions = reverseEnumeration
            ? [.longestEffectiveRangeNotRequired, .reverse]
            : [.longestEffectiveRangeNotRequired]

        enumerateAttribute(.token, in: enumerationRange, options: opts) { (value, range, stop) in

            // we are only interested in non-token body matches
            guard let tokenType = value as? TokenAttribute<LanguageConfiguration.Token>,
                  tokenType.isHead else { return }

        theSwitch: switch range.length {
        case 0:
            break

        case 1:   // we report one token (that possibly extents across mutliple characters
            guard let theToken = token(at: range.location) else { break theSwitch }
            block(theToken.type, theToken.range, stop)

        default:  // we report as many one-character tokens as the length of the `range` specifies
            guard let theRange: Range<Int> = Range(range) else { break theSwitch }

        forLoop: for idx in reverseEnumeration ? theRange.reversed() : Array(theRange) {

            block(tokenType.token, NSRange(location: idx, length: 1), stop)
            if stop.pointee.boolValue { break forLoop }

        }
        }
        }
    }

    /// If there is a bracket at the given location, return its matching bracket's location if it exists and is within
    /// the given range.
    ///
    /// - Parameters:
    ///   - location: Location of the original bracket (maybe opening or closing).
    ///   - range: Range of locations to consider for the matching bracket.
    /// - Returns: Character range of the lexeme of the matching bracket if it exists in the given `range`.
    ///
    func matchingBracket(forLocationAt location: Int, in range: NSRange) -> NSRange? {
        guard let bracketToken = token(at: location),
              bracketToken.type.isOpenBracket || bracketToken.type.isCloseBracket
        else { return nil }

        let matchingBracketTokenType = bracketToken.type.matchingBracket
        let searchRange: NSRange
        if bracketToken.type.isOpenBracket {

            // searching to the right
            searchRange = NSRange(location: location + 1, length: max(NSMaxRange(range) - location - 1, 0))

        } else {

            // searching to the left
            searchRange = NSRange(location: range.location, length: max(location - range.location, 0))

        }

        var level = 1
        var matchingRange: NSRange?
        enumerateTokens(in: searchRange, reverse: bracketToken.type.isCloseBracket) { (tokenType, range, stop) in

            if tokenType == bracketToken.type { level += 1 }  // nesting just got deeper
            else if tokenType == matchingBracketTokenType {   // matching bracket found

                if level > 1 { level -= 1 }     // but we are not yet at the topmost nesting level
                else {                          // this is the one actually matching the original bracket

                    matchingRange = range
                    stop.pointee = true

                }
            }
        }
        return matchingRange
    }
}
