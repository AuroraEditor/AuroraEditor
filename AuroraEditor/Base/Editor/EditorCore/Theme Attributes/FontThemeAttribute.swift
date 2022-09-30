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
}
