//
//  BoldThemeAttribute.swift
//  
//
//  Created by Matthew Davidson on 5/12/19.
//

import Foundation

import Cocoa

public class BoldThemeAttribute: TokenThemeAttribute, Codable {
    public var key: String = "bold"

    public init() {}

    public func apply(to attrStr: NSMutableAttributedString, withRange range: NSRange) {
        let font = attrStr.attributes(at: range.location, effectiveRange: nil)[.font] as? NSFont ?? NSFont()
        // TODO: Get this working. Somehow italics and underline work but not this.
        let newFont = NSFontManager.shared.convert(font, toHaveTrait: .boldFontMask)
        attrStr.addAttribute(.font, value: newFont, range: range)
    }
}
