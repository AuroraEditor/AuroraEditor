//
//  MessageViews.swift
//  
//
//  Created by Manuel M T Chakravarty on 23/03/2021.
//
//  Defines the visuals that present messages, both inline and as popovers.

import SwiftUI

/// SwiftUI view that displays an array of messages that lie on the same line. It supports switching between an inline
/// format and a full popup format by clicking/tapping on the message.
struct MessageView: View {
    struct Geometry {

        /// The maximum width that the inline view may use.
        let lineWidth: CGFloat

        /// The height of the inline view
        let lineHeight: CGFloat

        /// The maximum width that the popup view may use.
        let popupWidth: CGFloat

        /// The distance from the top where the popup view must be placed.
        let popupOffset: CGFloat
    }

    let messages: [Message]        // The array of messages that are displayed by this view
    let theme: Message.Theme    // The message display theme to use
    let geometry: Geometry

    @Binding var unfolded: Bool       // False => inline view; true => popup view

    var body: some View {

        // Overlaying the two different views (and switching between them by adjusting their opacity ensures that the
        // view is always sized the same and such that it can accomodate both modes).
        ZStack(alignment: .topTrailing) {

            // We adjust the position of the popup with spacers to ensure that the view frame extends appropriately
            // (this would not be the case if we used `.offset(x:y:)`).
            VStack {
                Spacer(minLength: geometry.popupOffset)
                HStack {
                    MessagePopupView(messages: messages, theme: theme)
                        .frame(maxWidth: geometry.popupWidth)
                        .onTapGesture { unfolded.toggle() }
                    Spacer(minLength: MessageView.popupRightSideOffset)
                }
            }
            .opacity(unfolded ? 1.0 : 0.0)

            MessageInlineView(messages: messages, theme: theme)
                .frame(minWidth: MessageView.minimumInlineWidth,
                       maxWidth: geometry.lineWidth,
                       maxHeight: geometry.lineHeight)
                .transition(.opacity)
                .onTapGesture { unfolded.toggle() }
                .opacity(unfolded ? 0.0 : 1.0)

        }
    }
}

extension MessageView {

    // FIXME: This should maybe depend on the font size and may need to be configurable.
    static let minimumInlineWidth = CGFloat(60)

    /// The distance of the popup view from the right side of the text container.
    static let popupRightSideOffset = CGFloat(20)
}

// MARK: - Message category themes
extension Message {

    /// Defines the colours and icons that identify each of the various message categories.
    typealias Theme = (Message.Category) -> (colour: OSColor, icon: Image)

    /// The default category theme
    static func defaultTheme(for category: Message.Category) -> (colour: OSColor, icon: Image) {
        switch category {
        case .live:
            return (colour: OSColor.green, icon: Image(systemName: "line.horizontal.3"))
        case .error:
            return (colour: OSColor.red, icon: Image(systemName: "xmark.circle.fill"))
        case .warning:
            return (colour: OSColor.yellow, icon: Image(systemName: "exclamationmark.triangle.fill"))
        case .informational:
            return (colour: OSColor.gray, icon: Image(systemName: "info.circle.fill"))
        }
    }
}

// MARK: - Previews
let message1 = Message(category: .error, length: 1, summary: "It's wrong!", description: nil),
    message2 = Message(category: .error, length: 1, summary: "Need to fix this.", description: nil),
    message3 = Message(category: .warning, length: 1, summary: "Looks dodgy.",
                       description: NSAttributedString(string: "This doesn't seem right and also totally unclear " +
                                                       "what it is supposed to do.")),
    message4 = Message(category: .live, length: 1, summary: "Thread 1", description: nil),
    message5 = Message(category: .informational, length: 1, summary: "Cool stuff!", description: nil)

struct MessageViewPreview: View {
    let messages: [Message]
    let theme: Message.Theme
    let geometry: MessageView.Geometry

    @State private var unfolded: Bool = false

    var body: some View {
        MessageView(messages: messages,
                    theme: theme,
                    geometry: geometry,
                    unfolded: $unfolded)
    }
}

struct MessageViews_Previews: PreviewProvider {

    static var previews: some View {

        // Inline view
        MessageInlineView(messages: [message1], theme: Message.defaultTheme)
            .frame(width: 80, height: 15, alignment: .center)
            .preferredColorScheme(.dark)

        MessageInlineView(messages: [message1], theme: Message.defaultTheme)
            .frame(width: 80, height: 25, alignment: .center)
            .preferredColorScheme(.dark)

        VStack {

            MessageInlineView(messages: [message1, message2], theme: Message.defaultTheme)
                .frame(width: 180, height: 15, alignment: .center)
                .preferredColorScheme(.dark)

            MessageInlineView(messages: [message1, message2, message3], theme: Message.defaultTheme)
                .frame(width: 180, height: 15, alignment: .center)
                .preferredColorScheme(.dark)

        }

        MessageInlineView(messages: [message1, message2, message3], theme: Message.defaultTheme)
            .frame(width: 180, height: 15, alignment: .center)
            .preferredColorScheme(.light)

        // Popup view
        MessagePopupView(messages: [message1], theme: Message.defaultTheme)
            .font(.system(size: 32))
            .frame(maxWidth: 320, minHeight: 15)
            .preferredColorScheme(.dark)

        MessagePopupView(messages: [message1, message4], theme: Message.defaultTheme)
            .frame(maxWidth: 320, minHeight: 15)
            .preferredColorScheme(.dark)

        MessagePopupView(messages: [message1, message2, message3], theme: Message.defaultTheme)
            .frame(maxWidth: 320, minHeight: 15)
            .preferredColorScheme(.dark)

        MessagePopupView(messages: [message1, message5, message2, message4, message3], theme: Message.defaultTheme)
            .frame(maxWidth: 320, minHeight: 15)
            .preferredColorScheme(.dark)

        MessagePopupView(messages: [message1, message5, message2, message4, message3], theme: Message.defaultTheme)
            .frame(maxWidth: 320, minHeight: 15)
            .preferredColorScheme(.light)

        // Combined view
        ZStack(alignment: .topTrailing) {

            Rectangle()
                .foregroundColor(Color.red.opacity(0.1))
                .frame(height: 30)
            HStack { Text("main = putStrLn \"Hello World!\""); Spacer() }
            StatefulMessageView(messages: [message1, message5, message2, message4, message3],
                                theme: Message.defaultTheme,
                                geometry: MessageView.Geometry(lineWidth: 150,
                                                               lineHeight: 15,
                                                               popupWidth: 300,
                                                               popupOffset: 30),
                                fontSize: 15,
                                unfolded: StatefulMessageView.ObservableBool(bool: false))
            .offset(y: 18)
        }
        .frame(width: 400, height: 300, alignment: .topTrailing)

    }
}
