//
//  FontThemeAttribute.swift
//  
//
//  Created by Matthew Davidson on 4/12/19.
//

import Foundation
import EditorCore

public class FontThemeAttribute: TokenThemeAttribute {

    public let key = "font-style"
    public let font: Font

    public init(font: Font) {
        self.font = font
    }

    public func apply(to attrStr: NSMutableAttributedString, withRange range: NSRange) {
        attrStr.addAttribute(.font, value: font, range: range)
    }
}
