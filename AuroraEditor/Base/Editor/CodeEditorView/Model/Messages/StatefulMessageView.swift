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
    let messages: [Message]              // The array of messages that are displayed by this view
    let theme: Message.Theme          // The message display theme to use
    let geometry: MessageView.Geometry   // The geometry constrains for the view
    let fontSize: CGFloat                // Font size to use for messages

    @ObservedObject var unfolded: ObservableBool  // `true` iff the view shows the popup flavour

    /// The unfolding state needs to be communicated between the SwiftUI view and the external world. Hence, we need to
    /// go via an `ObservableObject`.
    class ObservableBool: ObservableObject {
        @Published var bool: Bool

        init(bool: Bool) {
            self.bool = bool
        }
    }

    var body: some View {
        MessageView(messages: messages,
                    theme: theme,
                    geometry: geometry,
                    unfolded: $unfolded.bool)
        .font(.system(size: fontSize))
        .fixedSize()    // to enforce intrinsic size in the encapsulating `NSHostingView`
    }
}

extension StatefulMessageView {

    class HostingView: NSView {
        private var hostingView: NSHostingView<StatefulMessageView>?

        private let messages: [Message]
        private let theme: Message.Theme
        private let fontSize: CGFloat

        /// Unfolding status as sharable state.
        private let unfoldedState = StatefulMessageView.ObservableBool(bool: false)

        var geometry: MessageView.Geometry {
            didSet { reconfigure() }
        }
        var unfolded: Bool {
            get { unfoldedState.bool }
            set { unfoldedState.bool = newValue }
        }

        init(messages: [Message], theme: @escaping Message.Theme, geometry: MessageView.Geometry, fontSize: CGFloat) {
            self.messages = messages
            self.theme = theme
            self.geometry = geometry
            self.fontSize = fontSize
            super.init(frame: .zero)

            self.translatesAutoresizingMaskIntoConstraints = false

            self.hostingView = NSHostingView(rootView: StatefulMessageView(messages: messages,
                                                                           theme: theme,
                                                                           geometry: geometry,
                                                                           fontSize: fontSize,
                                                                           unfolded: unfoldedState))
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

        @objc dynamic required init?(coder aDecoder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }

        private func reconfigure() {
            self.hostingView?.rootView = StatefulMessageView(messages: messages,
                                                             theme: theme,
                                                             geometry: geometry,
                                                             fontSize: fontSize,
                                                             unfolded: unfoldedState)
        }
    }
}
