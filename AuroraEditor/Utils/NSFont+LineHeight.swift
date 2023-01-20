//
//  NSFont+LineHeight.swift
//  Aurora Editor
//
//  Created by Lukas Pistrol on 28.05.22.
//  Copyright © 2023 Aurora Company. All rights reserved.
//

import AppKit

public extension NSFont {
    /// The default line height of the font.
    var lineHeight: Double {
        NSLayoutManager().defaultLineHeight(for: self)
    }
}
