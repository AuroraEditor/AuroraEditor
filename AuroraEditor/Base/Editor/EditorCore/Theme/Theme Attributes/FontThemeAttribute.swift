//
//  FontThemeAttribute.swift
//  
//
//  Created by Matthew Davidson on 4/12/19.
//

import Foundation
import Cocoa

public class FontThemeAttribute: TokenThemeAttribute {

    public let key = "font-style"
    public let font: NSFont

    public init(font: NSFont) {
        self.font = font
    }

    public func apply(to attrStr: NSMutableAttributedString, withRange range: NSRange) {
        attrStr.addAttribute(.font, value: font, range: range)
    }

    enum Keys: CodingKey {
        case font
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: Keys.self)
        guard let font = font as? CodableFont else {
            try container.encode(font as? CodableFont, forKey: .font)
            return
        }
        try container.encode(font, forKey: .font)
    }

    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: Keys.self)
        self.font = try container.decode(CodableFont.self, forKey: .font).nsFont
    }
}

private class CodableFont: NSFont, Codable {
    var nsFont: NSFont { self as NSFont }
}
