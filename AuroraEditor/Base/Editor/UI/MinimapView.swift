//
//  MinimapView.swift
//  AuroraEditor
//
//  Created by TAY KAI QUAN on 16/9/22.
//  Copyright © 2022 Aurora Company. All rights reserved.
//

import SwiftUI

struct MinimapView: View {
    @Binding var attributedTextItems: [AttributedStringItem]
    @Binding var scrollAmount: CGFloat

    @ObservedObject
    private var sharedObjects: SharedObjects = .shared

    var body: some View {
        ZStack(alignment: .topLeading) {
            Color.black.opacity(0.2)
            GeometryReader { proxy in
                ZStack(alignment: .topLeading) {
                    Color.gray.opacity(0.5)
                        .frame(height: minimapLineHeight)
                        .offset(y: CGFloat(sharedObjects.caretPos.line) * minimapLineHeight * 1.5)
                    ForEach(attributedTextItems) { textItem in
                        if let color = textItem.attributes[.foregroundColor] as? NSColor {
                            Color(nsColor: color).opacity(0.7)
                                .frame(width: CGFloat(textItem.text.count) * minimapMultiplier,
                                       height: minimapLineHeight)
                                .offset(x: CGFloat(textItem.charactersFromStart) * minimapMultiplier,
                                        y: CGFloat(textItem.lineNumber) * (minimapLineHeight * 1.5))
                        }
                    }
                }
                // the scrollable area is the total number of lines * line height, minus the view height
                // however, if the view height is > the scrollable area, do not scroll.
                .offset(y: max(0,
                            (CGFloat(attributedTextItems.last?.lineNumber ?? 0) * minimapLineHeight * 1.5
                            - proxy.size.height)) *
                // the offset is the scrollable area * scrollAmount, inverted
                            scrollAmount * -1)
            }
        }
    }

    let minimapMultiplier: CGFloat = 0.8
    let minimapLineHeight: CGFloat = 2
}
