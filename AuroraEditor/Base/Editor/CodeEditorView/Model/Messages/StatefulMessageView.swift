//
//  StatefulMessageView.swift
//  Aurora Editor
//
//  Created by TAY KAI QUAN on 18/9/22.
//  Copyright © 2023 Aurora Company. All rights reserved.
//

import SwiftUI

/// SwiftUI view that displays an array of messages that lie on the same line. It supports switching between an inline
/// and popup view by tapping.
struct StatefulMessageView: View {
    /// The array of messages that are displayed by this view
    let messages: [Message]

    /// The message display theme to use
    let theme: Message.Theme

    /// The geometry constrains for the view
    let geometry: MessageView.Geometry

    /// Font size to use for messages
    let fontSize: CGFloat

    /// Whether the view is unfolded (i.e., showing the full popup view) or not.
    /// `true` iff the view shows the popup flavour
    @ObservedObject
    var unfolded: ObservableBool

    /// The unfolding state needs to be communicated between the SwiftUI view and the external world. Hence, we need to
    /// go via an `ObservableObject`.
    class ObservableBool: ObservableObject {
        /// The boolean value
        @Published var bool: Bool

        /// Initialiser
        /// 
        /// - Parameter bool: The initial boolean value
        init(bool: Bool) {
            self.bool = bool
        }
    }

    /// The view body
    var body: some View {
        MessageView(messages: messages,
                    theme: theme,
                    geometry: geometry,
                    unfolded: $unfolded.bool)
        .font(.system(size: fontSize))
        // to enforce intrinsic size in the encapsulating `NSHostingView`
        .fixedSize()
    }
}

extension StatefulMessageView {
    /// A `NSView` that hosts a `StatefulMessageView`.
    class HostingView: NSView {
        /// The hosting view
        private var hostingView: NSHostingView<StatefulMessageView>?

        /// The messages to display
        private let messages: [Message]

        /// The display theme to use
        private let theme: Message.Theme

        /// The font size constrains for the view
        private let fontSize: CGFloat

        /// Unfolding status as sharable state.
        private let unfoldedState = StatefulMessageView.ObservableBool(bool: false)

        /// The geometry constrains for the view
        var geometry: MessageView.Geometry {
            didSet { reconfigure() }
        }

        /// Whether the view is unfolded (i.e., showing the full popup view) or not.
        var unfolded: Bool {
            get { unfoldedState.bool }
            set { unfoldedState.bool = newValue }
        }

        /// Initialiser for the StatefulMessageView
        /// 
        /// - Parameter messages: The messages to display
        /// - Parameter theme: The display theme to use
        /// - Parameter geometry: The geometry constrains for the view
        /// - Parameter fontSize: The font size constrains for the view
        init(messages: [Message], theme: @escaping Message.Theme, geometry: MessageView.Geometry, fontSize: CGFloat) {
            self.messages = messages
            self.theme = theme
            self.geometry = geometry
            self.fontSize = fontSize
            super.init(frame: .zero)

            self.translatesAutoresizingMaskIntoConstraints = false

            self.hostingView = NSHostingView(rootView: StatefulMessageView(
                messages: messages,
                theme: theme,
                geometry: geometry,
                fontSize: fontSize,
                unfolded: unfoldedState
            ))
            hostingView?.translatesAutoresizingMaskIntoConstraints = false
            if let view = hostingView {

                addSubview(view)
                let constraints = [
                    view.topAnchor.constraint(equalTo: self.topAnchor),
                    view.bottomAnchor.constraint(equalTo: self.bottomAnchor),
                    view.leftAnchor.constraint(equalTo: self.leftAnchor),
                    view.rightAnchor.constraint(equalTo: self.rightAnchor)
                ]
                NSLayoutConstraint.activate(constraints)

            }
        }

        /// Initialiser for the StatefulMessageView
        /// 
        /// - Parameter coder: The decoder
        @objc dynamic required init?(coder aDecoder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }

        /// Reconfigures the view
        private func reconfigure() {
            self.hostingView?.rootView = StatefulMessageView(
                messages: messages,
                theme: theme,
                geometry: geometry,
                fontSize: fontSize,
                unfolded: unfoldedState
            )
        }
    }
}
