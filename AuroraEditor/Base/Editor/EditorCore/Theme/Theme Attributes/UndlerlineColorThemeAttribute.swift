//
//  UnderlineAEColorThemeAttribute.swift
//  
//
//  Created by Matthew Davidson on 23/12/19.
//

import Foundation

import Cocoa

public class UnderlineThemeAttribute: TokenThemeAttribute, Codable {

    public let key = "underline-AEColor"
    public let AEColor: AEColor
    public let style: NSUnderlineStyle

    public init(AEColor: AEColor, style: NSUnderlineStyle = .single) {
        self.AEColor = AEColor
        self.style = style
    }

    public func apply(to attrStr: NSMutableAttributedString, withRange range: NSRange) {
        attrStr.addAttribute(.underlineColor, value: AEColor, range: range)
        attrStr.addAttribute(.underlineStyle, value: style.rawValue, range: range)
    }
}
