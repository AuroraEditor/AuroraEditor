//
//  FontWithLineHeight.swift
//  Aurora Editor
//
//  Created by Nanashi Li on 16/09/2023.
//  Copyright © 2023 Aurora Company. All rights reserved.
//

import SwiftUI

// Extracted from:
// https://stackoverflow.com/a/64652348
struct FontWithLineHeight: ViewModifier {
    let font: NSFont
    let lineHeight: CGFloat

    func body(content: Content) -> some View {
        content
            .font(Font(font))
            .lineSpacing(lineHeight - font.xHeight)
            .padding(.vertical, (lineHeight - font.xHeight) / 2)
    }
}
