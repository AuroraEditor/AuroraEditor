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

    @ObservedObject
    private var sharedObjects: SharedObjects = .shared

    var body: some View {
        ZStack(alignment: .topLeading) {
            Color.black.opacity(0.2)
                Color.gray.opacity(0.5)
                    .frame(height: minimapLineHeight)
                    .offset(y: CGFloat(sharedObjects.caretPos.line) * minimapLineHeight)
            ForEach(attributedTextItems) { textItem in
                if let color = textItem.attributes[.foregroundColor] as? NSColor {
                    Color(nsColor: color)
                        .frame(width: CGFloat(textItem.text.count) * minimapMultiplier,
                               height: minimapLineHeight)
                        .offset(x: CGFloat(textItem.charactersFromStart) * minimapMultiplier,
                                y: CGFloat(textItem.lineNumber) * (minimapLineHeight * 1.5))
                }
            }
        }
    }

    let minimapMultiplier: CGFloat = 0.8
    let minimapLineHeight: CGFloat = 2
}
