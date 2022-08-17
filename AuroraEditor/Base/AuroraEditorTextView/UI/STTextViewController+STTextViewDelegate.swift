//
//  STTextViewController+STTextViewDelegate.swift
//  AuroraEditorTextView
//
//  Created by Lukas Pistrol on 28.05.22.
//

import AppKit

extension STTextViewController {
    /// Text did change
    /// - Parameter notification: notification description
    public func textDidChange(_ notification: Notification) {
        Log.info("Text did change")
    }

    /// Text should change
    /// - Parameters:
    ///   - textView: textView description
    ///   - affectedCharRange: affectedCharRange description
    ///   - replacementString: replacementString description
    /// - Returns: description
    public func textView(
        _ textView: STTextView,
        shouldChangeTextIn affectedCharRange: NSTextRange,
        replacementString: String?
    ) -> Bool {
        // Don't add '\t' characters
        if replacementString == "\t" {
            return false
        }
        return true
    }

    /// Text did change
    /// - Parameters:
    ///   - textView: textView description
    ///   - affectedCharRange: affectedCharRange description
    ///   - replacementString: replacementString description
    public func textView(
        _ textView: STTextView,
        didChangeTextIn affectedCharRange: NSTextRange,
        replacementString: String
    ) {
        if !updateText {
            updateText = true
            textView.autocompleteBracketPairs(replacementString)
            Log.info("Did change text in \(affectedCharRange) | \(replacementString)")

            // highlight()
            setStandardAttributes()

            textView.setString(
                AEHighlight().highlight(
                    code: textView.string,
                    themeString: ThemeModel.shared.selectedTheme?.highlightrThemeString
                )
            )
//            // TODO: Move Caret position.

            updateText = false
        }
    }

    public func textView(_ textView: STTextView, didMoveCaretTo row: Int, column: Int) {
        // Update status bar using `SharedObjects`
        SharedObjects.shared.caretPos = .init(line: row, column: column)
    }
}
