//
//  NSColorThemeAttribute.swift
//  Aurora Editor
//
//  Created by Matthew Davidson on 4/12/19.
//  Copyright © 2023 Aurora Company. All rights reserved.
//

import Foundation
import AppKit

public class ColorThemeAttribute: TokenThemeAttribute, Codable {

    public let key = "NSColor"
    public let color: NSColor

    public init(color: NSColor) {
        self.color = color
    }

    public func apply(to attrStr: NSMutableAttributedString, withRange range: NSRange) {
        attrStr.addAttribute(.foregroundColor, value: color, range: range)
    }

    enum Keys: CodingKey {
        case color
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: Keys.self)
        try container.encode(color.hex, forKey: .color)
    }

    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: Keys.self)
        self.color = NSColor(hex: try container.decode(Int.self, forKey: .color))
    }
}
