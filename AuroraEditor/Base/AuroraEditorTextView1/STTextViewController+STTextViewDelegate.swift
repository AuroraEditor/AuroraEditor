//
//  STTextViewController+STTextViewDelegate.swift
//  CodeEditTextView
//
//  Created by Lukas Pistrol on 28.05.22.
//

import AppKit
import STTextView

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
}
