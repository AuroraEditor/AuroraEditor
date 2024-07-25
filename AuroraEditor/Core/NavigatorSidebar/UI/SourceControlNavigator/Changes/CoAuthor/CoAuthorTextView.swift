//
//  CoAuthorTextView.swift
//  Aurora Editor
//
//  Created by Nanashi Li on 2024/07/16.
//  Copyright © 2024 Aurora Company. All rights reserved.
//

import SwiftUI

struct CoAuthorTextField: NSViewRepresentable {
    @Binding var text: String
    var onTextChange: (String) -> Void

    func makeNSView(context: Context) -> NSTextField {
        let textField = NSTextField()
        textField.delegate = context.coordinator
        textField.font = .systemFont(
            ofSize: 11,
            weight: .medium
        )
        textField.isBordered = false
        textField.backgroundColor = .clear
        textField.focusRingType = .none
        return textField
    }

    func updateNSView(_ nsView: NSTextField, context: Context) {
        nsView.stringValue = text
        DispatchQueue.main.async {
            nsView.currentEditor()?.selectedRange = NSRange(
                location: text.count,
                length: 0
            )
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, NSTextFieldDelegate {
        var parent: CoAuthorTextField
        var lastText: String = ""

        init(_ parent: CoAuthorTextField) {
            self.parent = parent
            self.lastText = parent.text
        }

        func controlTextDidChange(_ obj: Notification) {
            guard let textField = obj.object as? NSTextField else { return }

            let newText = textField.stringValue

            if newText.count < lastText.count {
                // Text was deleted
                let updatedText = removeLastMentionIfNeeded(from: newText)
                parent.text = updatedText
                textField.stringValue = updatedText
            } else {
                parent.text = newText
            }

            lastText = parent.text
            parent.onTextChange(parent.text)
        }

        private func removeLastMentionIfNeeded(from text: String) -> String {
            let components = text.split(
                separator: " ",
                omittingEmptySubsequences: false
            )
            guard let lastComponent = components.last else { return text }

            if lastComponent.hasPrefix("@") && lastComponent.count > 1 {
                // Remove the entire last mention
                return components.dropLast().joined(separator: " ")
            }

            return text
        }
    }
}
