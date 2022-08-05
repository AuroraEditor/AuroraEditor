//
//  STTextViewController+STTextViewDelegate.swift
//  AuroraEditorTextView
//
//  Created by Lukas Pistrol on 28.05.22.
//

import AppKit

extension STTextViewController {
    /// <#Description#>
    /// - Parameter notification: <#notification description#>
    public func textDidChange(_ notification: Notification) {
        print("Text did change")
    }

    /// <#Description#>
    /// - Parameters:
    ///   - textView: <#textView description#>
    ///   - affectedCharRange: <#affectedCharRange description#>
    ///   - replacementString: <#replacementString description#>
    /// - Returns: <#description#>
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

    /// <#Description#>
    /// - Parameters:
    ///   - textView: <#textView description#>
    ///   - affectedCharRange: <#affectedCharRange description#>
    ///   - replacementString: <#replacementString description#>
    public func textView(
        _ textView: STTextView,
        didChangeTextIn affectedCharRange: NSTextRange,
        replacementString: String
    ) {
        textView.autocompleteBracketPairs(replacementString)
        print("Did change text in \(affectedCharRange) | \(replacementString)")

        // highlight()
        setStandardAttributes()

        self.text.wrappedValue = textView.string
    }

    public func textView(_ textView: STTextView, didMoveCaretTo row: Int, column: Int) {
        // Update status bar using `SharedObjects`
        SharedObjects.shared.caretPos = .init(line: row, column: column)
    }
}
