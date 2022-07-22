//
//  NSFont+LineHeight.swift
//  CodeEditTextView
//
//  Created by Lukas Pistrol on 28.05.22.
//

import AppKit

public extension NSFont {
    /// The default line height of the font.
    var lineHeight: Double {
        NSLayoutManager().defaultLineHeight(for: self)
    }
}
