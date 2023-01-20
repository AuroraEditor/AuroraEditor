//
//  MessagePopupView.swift
//  Aurora Editor
//
//  Created by TAY KAI QUAN on 18/9/22.
//  Copyright © 2023 Aurora Company. All rights reserved.
//

import SwiftUI

// MARK: - Popup view

/// Key to track the width for a set of message popup views.
private struct PopupWidth: PreferenceKey, EnvironmentKey {

    static let defaultValue: CGFloat? = nil
    static func reduce(value: inout CGFloat?, nextValue: () -> CGFloat?) {
        if let next = nextValue() { value = value.flatMap { max(next, $0) } ?? next }
    }
}

/// Accessor for the environment value identified by the key.
extension EnvironmentValues {

    var popupWidth: CGFloat? {
        get { self[PopupWidth.self] }
        set { self[PopupWidth.self] = newValue }
    }
}

private struct MessageBorder: ViewModifier {
    let cornerRadius: CGFloat

    @Environment(\.colorScheme) var colourScheme: ColorScheme

    func body(content: Content) -> some View {

        let shadowColour = colourScheme == .dark ? Color(.sRGBLinear, white: 0, opacity: 0.66)
        : Color(.sRGBLinear, white: 0, opacity: 0.33)

        if colourScheme == .dark {
            return AnyView(content
                .shadow(color: shadowColour, radius: 2, y: 2)
                .overlay(RoundedRectangle(cornerRadius: cornerRadius)
                    .stroke(Color.white.opacity(0.3), lineWidth: 1))
                    .padding(1)
                    .overlay(RoundedRectangle(cornerRadius: cornerRadius)
                        .stroke(Color.black, lineWidth: 1)))
        } else {
            return AnyView(content
                .shadow(color: shadowColour, radius: 1, y: 1)
                .overlay(RoundedRectangle(cornerRadius: cornerRadius)
                    .stroke(Color.black.opacity(0.2), lineWidth: 1)))
        }
    }
}

extension View {
    fileprivate func messageBorder(cornerRadius: CGFloat) -> some View {
        modifier(MessageBorder(cornerRadius: cornerRadius))
    }
}

/// A view that display all the information of a list of messages.
///
/// NB: The array of messages may not be empty.
private struct MessagePopupCategoryView: View {
    let category: Message.Category
    let messages: [Message]
    let theme: Message.Theme

    let cornerRadius: CGFloat = 10

    @Environment(\.colorScheme) var colourScheme: ColorScheme
    @Environment(\.popupWidth)  var popupWidth: CGFloat?

    var body: some View {

        let backgroundColour = colourScheme == .dark ? Color.black : Color.white
        let colour = Color(theme(category).colour)

        let theActualView =
        HStack(spacing: 0) {

            // Category icon
            ZStack(alignment: .top) {
                colour.opacity(0.5)
                Text("XX")       // We want the icon to have the height of text
                    .hidden()
                    .overlay( theme(category).icon.frame(alignment: .center) )
                    .padding([.leading, .trailing], 5)
                    .padding([.top, .bottom], 3)
            }.fixedSize(horizontal: true, vertical: false)

            // Vertical stack of message
            VStack(alignment: .leading, spacing: 6) {
                ForEach(0..<messages.count, id: \.self) { message in
                    Text(messages[message].summary)
                    if let description = messages[message].description { Text(description.string) }
                }
            }
            .padding([.leading, .trailing], 5)
            .padding([.top, .bottom], 3)
            .frame(maxWidth: popupWidth, alignment: .leading)       // Constrain width if `popupWidth` is not `nil`
            .background(colour.opacity(0.3))
            .background(GeometryReader { proxy in                   // Propagate current width up the view tree
                Color.clear.preference(key: PopupWidth.self, value: proxy.size.width)
            })

        }

        // The construction with the overlay is necessary to reliably get the theme colour underneath the
        // category icon to extend to vertically fill the available space. Essentially, the first use of
        // `theActualView` calculates the height, which depends on the vertical stack of messages, and inside
        // the overlay, we then just use the previously calculated height.
        theActualView
            .hidden()
            .overlay(theActualView)
            .background(backgroundColour)
            .cornerRadius(cornerRadius)
            .fixedSize(horizontal: false, vertical: true)           // horizontal must wrap and vertical extend
            .messageBorder(cornerRadius: cornerRadius)
    }
}

struct MessagePopupView: View {
    let messages: [Message]
    let theme: Message.Theme

    /// The width of the text in the message category with the widest text.
    @State private var popupWidth: CGFloat?

    var body: some View {

        let categories = messagesByCategory(messages)

        VStack(spacing: 4) {
            ForEach(0..<categories.count, id: \.self) { category in
                MessagePopupCategoryView(
                    category: categories[category].0,
                    messages: categories[category].1,
                    theme: theme
                )
            }
        }
        .background(Color.clear)
        // Update the state variable with current width...
        .onPreferenceChange(PopupWidth.self) { self.popupWidth = $0 }
        // ...and propagate that value down the view tree.
        .environment(\.popupWidth, popupWidth)
    }
}
