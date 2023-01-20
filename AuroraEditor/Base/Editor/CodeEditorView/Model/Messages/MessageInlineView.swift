//
//  MessageInlineView.swift
//  Aurora Editor
//
//  Created by TAY KAI QUAN on 18/9/22.
//  Copyright © 2023 Aurora Company. All rights reserved.
//

import SwiftUI

/// A view that summarises the message for a line, such that it can be displayed on the right hand side of the line.
/// The view uses the entire height offered.
///
/// NB: The array of messages may not be empty.
struct MessageInlineView: View {
    let messages: [Message]
    let theme: Message.Theme

    var body: some View {

        let categories = messagesByCategory(messages).map { $0.key }

        GeometryReader { geometryProxy in

            let height = geometryProxy.size.height
            let colour = Color(theme(categories[0]).colour)

            HStack {

                Spacer()

                HStack(alignment: .center, spacing: 0) {

                    // Category summary
                    HStack(alignment: .center, spacing: 0) {

                        // Overall message count
                        let count = messages.count
                        if count > 1 {
                            Text("\(count)")
                                .padding([.leading, .trailing], 3)
                        }

                        // All category icons
                        HStack(alignment: .center, spacing: 0) {
                            ForEach(0..<categories.count, id: \.self) { cat in
                                HStack(alignment: .center, spacing: 0) {
                                    theme(categories[cat]).icon
                                        .padding([.leading, .trailing], 2)
                                }
                            }
                        }
                        .padding([.leading, .trailing], 2)

                    }
                    .frame(height: height)
                    .background(colour.opacity(0.5))
                    .roundedCornersOnTheLeft(cornerRadius: 5)

                    // Transparent narrow separator
                    Divider()
                        .background(Color.clear)

                    // Topmost message of the highest priority category
                    HStack {
                        Text(messages.filter { $0.category == categories[0] }.first?.summary ?? "")
                            .padding([.leading, .trailing], 5)
                    }
                    .frame(height: height)
                    .background(colour.opacity(0.5))

                }
            }
        }
    }
}
