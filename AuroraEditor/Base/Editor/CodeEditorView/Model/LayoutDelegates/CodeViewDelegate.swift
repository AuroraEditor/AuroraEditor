//
//  CodeViewDelegate.swift
//  Aurora Editor
//
//  Created by TAY KAI QUAN on 18/9/22.
//  Copyright © 2023 Aurora Company. All rights reserved.
//

import AppKit

class CodeViewDelegate: NSObject, NSTextViewDelegate {

    // Hooks for events
    var textDidChange: ((NSTextView) -> Void)?
    var selectionDidChange: ((NSTextView) -> Void)?

    // MARK: NSTextViewDelegate protocol

    func textDidChange(_ notification: Notification) {
        guard let textView = notification.object as? NSTextView else { return }
        NotificationCenter.default.post(name: .didBeginEditing, object: nil)

        textDidChange?(textView)
    }

    func textViewDidChangeSelection(_ notification: Notification) {
        guard let textView = notification.object as? NSTextView else { return }

        selectionDidChange?(textView)
    }
}
