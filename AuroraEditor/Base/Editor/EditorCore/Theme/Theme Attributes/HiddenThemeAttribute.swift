//
//  HiddenThemeAttribute.swift
//  Aurora Editor
//
//  Created by Matthew Davidson on 26/12/19.
//  Copyright © 2023 Aurora Company. All rights reserved.
//

import Foundation

public class HiddenThemeAttribute: TokenThemeAttribute, Codable {

    public static let Key = NSAttributedString.Key(rawValue: "EditorUI.Hidden")

    public var key = "hidden"
    public let hidden: Bool

    public init(hidden: Bool = true) {
        self.hidden = hidden
    }

    public func apply(to attrStr: NSMutableAttributedString, withRange range: NSRange) {
        attrStr.addAttribute(Self.Key, value: hidden, range: range)
    }
}
