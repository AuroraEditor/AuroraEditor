//
//  ColorThemeAttribute.swift
//  
//
//  Created by Matthew Davidson on 4/12/19.
//

import Foundation
import EditorCore

public class ColorThemeAttribute: TokenThemeAttribute {

    public let key = "color"
    public let color: Color

    public init(color: Color) {
        self.color = color
    }

    public func apply(to attrStr: NSMutableAttributedString, withRange range: NSRange) {
        attrStr.addAttribute(.foregroundColor, value: color, range: range)
    }
}
