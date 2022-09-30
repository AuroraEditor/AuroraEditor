//
//  AEColorThemeAttribute.swift
//  
//
//  Created by Matthew Davidson on 4/12/19.
//

import Foundation

public class ColorThemeAttribute: TokenThemeAttribute, Codable {

    public let key = "AEColor"
    public let AEColor: AEColor

    public init(color: AEColor) {
        self.AEColor = color
    }

    public func apply(to attrStr: NSMutableAttributedString, withRange range: NSRange) {
        attrStr.addAttribute(.foregroundColor, value: AEColor, range: range)
    }
}
