//
//  ActionAwareInput.swift
//  Aurora Editor
//
//  Created by TAY KAI QUAN on 2/9/22.
//  Copyright © 2023 Aurora Company. All rights reserved.
//
//  CREDITS: Avdept, CodeEdit pull #545 https://github.com/CodeEditApp/CodeEdit/pull/545
//

import Foundation
import SwiftUI

/// A special NSTextView based input that allows to override onkeyDown events and add according handlers.
/// Very useful when need to use arrows to navigate through the list of items that matches entered text
public struct ActionAwareInput: NSViewRepresentable {
    /// The color scheme
    @Environment(\.colorScheme)
    var colorScheme: ColorScheme

    /// The font color
    var fontColor: Color {
        colorScheme == .dark ? .white : .black
    }

    /// The onDown event handler
    var onDown: ((NSEvent) -> Bool)?

    /// The onTextChange event handler
    var onTextChange: ((String) -> Void)

    /// The text
    @Binding var text: String

    /// Creates a new instance of `ActionAwareInput`.
    /// 
    /// - Parameter context: The context.
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

    /// Updates the NSView.
    /// 
    /// - Parameter nsView: The NSView.
    /// - Parameter context: The context.
    public func updateNSView(_ nsView: NSViewType, context: Context) {
        nsView.textContainer?.textView?.string = text
        // This way we can update light/dark mode font color
        nsView.textContainer?.textView?.textColor = NSColor(fontColor)
    }
}

/// A special NSTextView based input that allows to override onkeyDown events and add according handlers.
class ActionAwareInputView: NSTextView, NSTextFieldDelegate {
    /// The onDown event handler
    var onDown: ((NSEvent) -> Bool)?

    /// The onTextChange event handler
    var onTextChange: ((String) -> Void)?

    /// Control.
    /// 
    /// - Parameter control: The control.
    /// - Parameter textView: The text view.
    /// - Parameter commandSelector: The command selector.
    /// 
    /// - Returns: A boolean value indicating whether the command was handled.
    func control(_ control: NSControl, textView: NSTextView, doCommandBy commandSelector: Selector) -> Bool {
        return true
    }

    /// Accepts first responder.
    override var acceptsFirstResponder: Bool { return true }

    /// Key down.
    /// 
    /// - Parameter event: The event.
    override public func keyDown(with event: NSEvent) {
        if onDown!(event) {
            // We don't want to pass event down the pipe if it was handled.
            // By handled I mean its keycode was used for something else than typing
            return
        }

        super.keyDown(with: event)
    }

    /// Did change text.
    override public func didChangeText() {
        onTextChange?(self.string)
    }
}
