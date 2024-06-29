//
//  SettingsTextEditor.swift
//  Aurora Editor
//
//  Created by Andrey Plotnikov on 07.05.2022.
//  Copyright © 2023 Aurora Company. All rights reserved.
//

import Foundation
import SwiftUI

/// A view that represents the settings for the text editor.
public struct SettingsTextEditor: View {
    /// The text binding
    @Binding
    var text: String

    /// The focus state
    @State
    private var isFocus: Bool = false

    /// The settings text editor view
    /// 
    /// - Parameter text: The text binding
    public init(text: Binding<String>) {
        self._text = text
    }

    /// The view body
    public var body: some View {
        Representable(text: $text, isFocused: $isFocus)
            .overlay(focusOverlay)
    }

    /// The focus overlay
    private var focusOverlay: some View {
      Rectangle().stroke(Color.accentColor.opacity(isFocus ? 0.4 : 0), lineWidth: 2)
    }
}

private extension SettingsTextEditor {
    /// A view that represents the text editor.
    struct Representable: NSViewRepresentable {
        /// The text binding
        @Binding var text: String

        /// The focus state
        @Binding var isFocused: Bool

        /// Makes the NSView
        /// 
        /// - Parameter context: The context
        ///
        /// - Returns: NSScrollView
        func makeNSView(context: Context) -> NSScrollView {
            let scrollView = NSTextView.scrollableTextView()
            scrollView.verticalScroller?.alphaValue = 0
            let textView = scrollView.documentView as? NSTextView
            textView?.backgroundColor = .windowBackgroundColor
            textView?.isEditable = true
            textView?.delegate = context.coordinator
            textView?.string = text
            return scrollView
        }

        /// Updates the NSView
        /// 
        /// - Parameter nsView: The NSView
        /// - Parameter context: The context
        func updateNSView(_ nsView: NSScrollView, context: Context) {

        }

        /// Makes the coordinator
        func makeCoordinator() -> Coordinator {
            Coordinator(parent: self)
        }

        /// The coordinator
        class Coordinator: NSObject, NSTextViewDelegate {
            /// The parent view
            var parent: Representable

            /// Creates a new instance of the coordinator
            /// 
            /// - Parameter parent: The parent view
            init(parent: Representable) {
                self.parent = parent
            }

            /// Text did begin editing
            /// 
            /// - Parameter notification: The notification
            func textDidBeginEditing(_ notification: Notification) {
                parent.isFocused = true
            }

            /// Text did end editing
            /// 
            /// - Parameter notification: The notification
            func textDidEndEditing(_ notification: Notification) {
                parent.isFocused = false
            }

            /// Text did change
            /// 
            /// - Parameter notification: The notification
            func textDidChange(_ notification: Notification) {
                guard let textView = notification.object as? NSTextView else {
                    return
                }

                // Update text
                self.parent.text = textView.string
            }
        }
    }

}
