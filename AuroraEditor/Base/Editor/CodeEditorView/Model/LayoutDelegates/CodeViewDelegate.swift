//
//  CodeViewDelegate.swift
//  Aurora Editor
//
//  Created by TAY KAI QUAN on 18/9/22.
//  Copyright © 2023 Aurora Company. All rights reserved.
//

import AppKit

/// Delegate for the code view.
class CodeViewDelegate: NSObject, NSTextViewDelegate {

    /// Text did change
    /// 
    /// - Parameter textView: text view
    /// 
    /// - Returns: void
    var textDidChange: ((NSTextView) -> Void)?

    /// Selection did change
    /// 
    /// - Parameter textView: text view
    /// 
    /// - Returns: void
    var selectionDidChange: ((NSTextView) -> Void)?

    // MARK: NSTextViewDelegate protocol

    /// Text did change
    /// 
    /// - Parameter notification: notification
    func textDidChange(_ notification: Notification) {
        guard let textView = notification.object as? NSTextView else { return }
        NotificationCenter.default.post(name: .didBeginEditing, object: nil)

        textDidChange?(textView)
    }

    /// Selection did change
    /// 
    /// - Parameter notification: notification
    func textViewDidChangeSelection(_ notification: Notification) {
        guard let textView = notification.object as? NSTextView else { return }

        selectionDidChange?(textView)
    }
}
