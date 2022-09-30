//
//  LigatureThemeAttribute.swift
//  
//
//  Created by Matthew Davidson on 26/12/19.
//

import Foundation

public class LigatureThemeAttribute: TokenThemeAttribute {

    public let key = "ligature"
    public let ligature: Int

    public init(ligature: Int) {
        self.ligature = ligature
    }

    public func apply(to attrStr: NSMutableAttributedString, withRange range: NSRange) {
        attrStr.addAttribute(.ligature, value: ligature, range: range)
    }
}
