//
//  HiddenThemeAttribute.swift
//  
//
//  Created by Matthew Davidson on 26/12/19.
//

import Foundation

public class HiddenThemeAttribute: TokenThemeAttribute {

    public static let Key = NSAttributedString.Key(rawValue: "EditorUI.Hidden")

    public let key = "hidden"
    public let hidden: Bool

    public init(hidden: Bool = true) {
        self.hidden = hidden
    }

    public func apply(to attrStr: NSMutableAttributedString, withRange range: NSRange) {
        attrStr.addAttribute(Self.Key, value: hidden, range: range)
    }
}
