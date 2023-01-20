//
//  CodeEditorView.swift
//  Aurora Editor
//
//  Created by Nanashi Li on 2022/09/24.
//  Copyright © 2023 Aurora Company. All rights reserved.
//

import AppKit
import SwiftUI

extension CodeEditor: NSViewRepresentable {
    /// Generates and returns a scroll view with a CodeView set as its document view.
    public func makeNSView(context: Context) -> NSScrollView {
        let loadedGrammar = GrammarJsonLoader.grammarFor(extension: fileExtension)

        // Set up text view with gutter
        let codeView = CodeView(frame: CGRect(x: 0, y: 0, width: 100, height: 40),
                                viewLayout: layout,
                                theme: theme,
                                mainGrammar: loadedGrammar)

        globalMainQueue.async {
            codeView.string = text
            codeView.codeStorageDelegate.lineMap.updateAfterEditing(string: text,
                                                                    range: NSRange(location: 0, length: text.count),
                                                                    changeInLength: text.count)
        }
        codeView.selectedRanges = position.selections.map { NSValue(range: $0) }

        codeView.isVerticallyResizable = true
        codeView.isHorizontallyResizable = false
        codeView.autoresizingMask = .width

        // Set up scroll view
        let scrollView = NSScrollView()
        scrollView.hasVerticalScroller = true
        scrollView.hasHorizontalRuler = false
        scrollView.drawsBackground = false
        scrollView.documentView = codeView

        if let delegate = codeView.delegate as? CodeViewDelegate {
            delegate.textDidChange = context.coordinator.textDidChange
            delegate.selectionDidChange = { textView in
                selectionDidChange(textView)
                textView.needsDisplay = true
                context.coordinator.selectionDidChange(textView)
            }
        }

        // We can't set the scroll position right away as the views are not properly sized yet. Thus, this needs to be
        // delayed.
        // TODO: The scroll fraction assignment still happens to soon if the initialisisation \
        // takes a long time, because we loaded a large file.
        // It be better if we could deterministically determine when initialisation is entirely \
        // finished and then set the scroll fraction at that point.
        globalMainQueue.async {
            scrollView.verticalScrollFraction = position.verticalScrollFraction
        }

        // The minimap needs to be vertically positioned in dependence on the scroll position of the main code view and
        // we need to keep track of the scroll position.
        context.coordinator.boundsChangedNotificationObserver
        = NotificationCenter.default.addObserver(forName: NSView.boundsDidChangeNotification,
                                                 object: scrollView.contentView,
                                                 queue: .main) { _ in

            codeView.adjustScrollPositionOfMinimap()
            context.coordinator.scrollPositionDidChange(scrollView)
        }

        // Report the initial message set, and reset the caret position
        DispatchQueue.main.async {
            updateMessages(in: codeView, with: context)

            context.coordinator.caretPosition = .init(line: 0, column: 0)
            for (id, AEExt) in ExtensionsManager.shared.loadedExtensions {
                Log.info(id, "didMoveCaret")
                AEExt.respond(
                    action: "didMoveCaret",
                    parameters: ["row": 0, "col": 0]
                )
            }
        }

        return scrollView
    }

    public func updateNSView(_ scrollView: NSScrollView, context: Context) {
        guard let codeView = scrollView.documentView as? CodeView else { return }
        context.coordinator.updatingView = true

        let selections = position.selections.map { NSValue(range: $0) }

        updateMessages(in: codeView, with: context)
        if text != codeView.string { codeView.string = text }  // Hoping for the string comparison fast path...
        if selections != codeView.selectedRanges { codeView.selectedRanges = selections }
        if abs(position.verticalScrollFraction - scrollView.verticalScrollFraction) > 0.0001 {
            scrollView.verticalScrollFraction = position.verticalScrollFraction
        }
        if theme.id != codeView.theme.id { codeView.theme = theme }
        if layout != codeView.viewLayout { codeView.viewLayout = layout }

        context.coordinator.updatingView = false
    }

    public func makeCoordinator() -> Coordinator {
        return Coordinator($text, $position, $caretPosition, $bracketCount, $currentToken)
    }

    public final class Coordinator: TCoordinator {
        var boundsChangedNotificationObserver: NSObjectProtocol?

        deinit {
            if let observer = boundsChangedNotificationObserver {
                NotificationCenter.default.removeObserver(observer)
            }
        }

        private func calculateCaretPosition(txt: String, pos: NSRange) -> CursorLocation {
            var row = 0
            var col = 0

            // Create the range
            let range = NSRange(location: 0, length: pos.upperBound)

            // Get only the text before the caret
            guard let txtStr = txt[range] else {
                fatalError("Failed to get caret position in document")
            }

            // Split newlines
            let splitValue = txtStr.components(separatedBy: "\n")

            // Check on what row we are
            row = splitValue.count

            if !splitValue.isEmpty {
                // We are > row 0, so count with the correct row
                // splitValue[row - 1], is the row contents.
                // .utf8.count gives us the (current) length of the string
                col = splitValue[row - 1].utf8.count
            } else {
                // .count gives us the (current) length of the string
                col = txtStr.count
            }

            for (id, AEExt) in ExtensionsManager.shared.loadedExtensions {
                Log.info(id, "didMoveCaret")
                AEExt.respond(
                    action: "didMoveCaret",
                    parameters: [
                        "row": row,
                        "col": col
                    ])
            }

            return .init(line: row, column: col)
        }

        private func getScopesAtCursor(txt: NSAttributedString, pos: Int) -> Token? {
            guard pos < txt.length else { return nil }
            let attributes = txt.attributes(at: pos, effectiveRange: nil)
            let token = attributes[.token] as? Token
            return token
        }

        private func getBracketCountAtCursor(txt: String, pos: Int) -> BracketCount {
            var bracketCount = BracketCount(
                roundBracketCount: 0,
                curlyBracketCount: 0,
                squareBracketCount: 0,
                bracketHistory: []
            )

            for char in String(txt[txt.startIndex..<txt.index(txt.startIndex, offsetBy: pos)]) {
                switch char {
                    // detect open brackets
                case "(":
                    bracketCount.roundBracketCount += 1
                    bracketCount.bracketHistory.append(.round)

                case "{":
                    bracketCount.curlyBracketCount += 1
                    bracketCount.bracketHistory.append(.curly)

                case "[":
                    bracketCount.squareBracketCount += 1
                    bracketCount.bracketHistory.append(.square)

                    // detect close brackets
                case ")":
                    bracketCount.roundBracketCount -= 1
                    if bracketCount.bracketHistory.last == .round {
                        _ = bracketCount.bracketHistory.popLast()
                    }

                case "}":
                    bracketCount.curlyBracketCount -= 1
                    if bracketCount.bracketHistory.last == .curly {
                        _ = bracketCount.bracketHistory.popLast()
                    }

                case "]":
                    bracketCount.squareBracketCount -= 1
                    if bracketCount.bracketHistory.last == .square {
                        _ = bracketCount.bracketHistory.popLast()
                    }

                default:
                    break
                }
            }

            return bracketCount
        }

        func textDidChange(_ textView: NSTextView) {
            guard !updatingView else { return }

            if self.text != textView.string {
                self.text = textView.string
            }
        }

        func selectionDidChange(_ textView: NSTextView) {
            guard !updatingView else { return }

            let newValue = textView.selectedRanges.map { $0.rangeValue }
            if self.position.selections != newValue {
                if let section = newValue.first {
                    self.caretPosition = calculateCaretPosition(txt: textView.text, pos: section)
                    if section.length == 0 {
                        self.currentToken = getScopesAtCursor(
                            txt: textView.attributedString(),
                            pos: section.lowerBound
                        )
                        self.bracketCount = getBracketCountAtCursor(
                            txt: textView.string,
                            pos: section.lowerBound
                        )
                    }
                }
                self.position.selections = newValue
            }
        }

        func scrollPositionDidChange(_ scrollView: NSScrollView) {
            guard !updatingView else { return }

            if abs(position.verticalScrollFraction - scrollView.verticalScrollFraction) > 0.0001 {
                position.verticalScrollFraction = scrollView.verticalScrollFraction
            }
        }
    }

    /// Update messages for a code view in the given context.
    private func updateMessages(in codeView: CodeView, with context: Context) {
        update(oldMessages: context.coordinator.lastMessages, to: messages, in: codeView)
        context.coordinator.lastMessages = messages
    }

    /// Update the message set of the given code view.
    private func update(oldMessages: Set<Located<Message>>,
                        to updatedMessages: Set<Located<Message>>,
                        in codeView: CodeView) {
        let messagesToAdd = updatedMessages.subtracting(oldMessages),
            messagesToRemove = oldMessages.subtracting(updatedMessages)

        for message in messagesToRemove { codeView.retract(message: message.entity) }
        for message in messagesToAdd { codeView.report(message: message) }
    }
}
