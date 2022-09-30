//
//  BoldThemeAttribute.swift
//  
//
//  Created by Matthew Davidson on 5/12/19.
//

import Foundation
import EditorCore
import Cocoa

public class BoldThemeAttribute: TokenThemeAttribute {
    public var key: String = "bold"

    public init() {}

    public func apply(to attrStr: NSMutableAttributedString, withRange range: NSRange) {
        let font = attrStr.attributes(at: range.location, effectiveRange: nil)[.font] as? NSFont ?? NSFont()

        let newFont = NSFontManager.shared.convert(font, toHaveTrait: .boldFontMask)
        attrStr.addAttribute(.font, value: newFont, range: range)
    }
}
