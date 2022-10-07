//
//  UnderlineNSColorThemeAttribute.swift
//  
//
//  Created by Matthew Davidson on 23/12/19.
//

import Foundation

import Cocoa

public class UnderlineThemeAttribute: TokenThemeAttribute, Codable {

    public let key = "underline-NSColor"
    public let color: NSColor
    public let style: NSUnderlineStyle

    public init(color: NSColor, style: NSUnderlineStyle = .single) {
        self.color = color
        self.style = style
    }

    public func apply(to attrStr: NSMutableAttributedString, withRange range: NSRange) {
        attrStr.addAttribute(.underlineColor, value: color, range: range)
        attrStr.addAttribute(.underlineStyle, value: style.rawValue, range: range)
    }

    enum Keys: CodingKey {
        case color, style
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: Keys.self)
        try container.encode(color.hex, forKey: .color)
        try container.encode(style.rawValue, forKey: .style)
    }

    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: Keys.self)
        self.color = NSColor(hex: try container.decode(Int.self, forKey: .color))
        self.style = NSUnderlineStyle(rawValue: try container.decode(Int.self, forKey: .style))
    }
}
