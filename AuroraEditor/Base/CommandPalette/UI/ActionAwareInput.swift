//
//  ActionAwareInput.swift
//  Aurora Editor
//
//  Created by TAY KAI QUAN on 2/9/22.
//  CREDITS: Avdept, CodeEdit pull #545 https://github.com/CodeEditApp/CodeEdit/pull/545
//

import Foundation
import SwiftUI

/// A special NSTextView based input that allows to override onkeyDown events and add according handlers.
/// Very useful when need to use arrows to navigate through the list of items that matches entered text
public struct ActionAwareInput: NSViewRepresentable {
    @Environment(\.colorScheme) var colorScheme: ColorScheme
    var fontColor: Color {
            colorScheme == .dark ? .white : .black
        }

    var onDown: ((NSEvent) -> Bool)?
    var onTextChange: ((String) -> Void)
    @Binding var text: String

    public func makeNSView(context: Context) -> some NSTextView {
        let input = ActionAwareInputView()
        input.textContainer?.maximumNumberOfLines = 1
        input.onTextChange = { newText in
            text = newText
            onTextChange(newText)
        }
        input.string = text
        input.onDown = onDown
        input.font = .systemFont(ofSize: 20, weight: .light)
        input.textColor = NSColor(fontColor)
        input.drawsBackground = false
        input.becomeFirstResponder()
        input.invalidateIntrinsicContentSize()

        return input
    }

    public func updateNSView(_ nsView: NSViewType, context: Context) {
        nsView.textContainer?.textView?.string = text
        // This way we can update light/dark mode font color
        nsView.textContainer?.textView?.textColor = NSColor(fontColor)
    }
}

class ActionAwareInputView: NSTextView, NSTextFieldDelegate {

    var onDown: ((NSEvent) -> Bool)?
    var onTextChange: ((String) -> Void)?

    func control(_ control: NSControl, textView: NSTextView, doCommandBy commandSelector: Selector) -> Bool {
        return true
    }

    override var acceptsFirstResponder: Bool { return true }

    override public func keyDown(with event: NSEvent) {
        if onDown!(event) {
            // We don't want to pass event down the pipe if it was handled.
            // By handled I mean its keycode was used for something else than typing
            return
        }

        super.keyDown(with: event)
    }

    override public func didChangeText() {
        onTextChange?(self.string)
    }

}
