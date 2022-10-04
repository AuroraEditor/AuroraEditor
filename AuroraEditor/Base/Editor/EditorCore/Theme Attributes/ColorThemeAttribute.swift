//
//  NSColorThemeAttribute.swift
//  
//
//  Created by Matthew Davidson on 4/12/19.
//

import Foundation

public class ColorThemeAttribute: TokenThemeAttribute, Codable {

    public let key = "NSColor"
    public let NSColor: NSColor

    public init(color: NSColor) {
        self.NSColor = color
    }

    public func apply(to attrStr: NSMutableAttributedString, withRange range: NSRange) {
        attrStr.addAttribute(.foregroundColor, value: NSColor, range: range)
    }
}
