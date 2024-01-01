//
//  KernThemeAttribute.swift
//  Aurora Editor
//
//  Created by Matthew Davidson on 26/12/19.
//  Copyright © 2023 Aurora Company. All rights reserved.
//

import Foundation

public class KernThemeAttribute: TokenThemeAttribute, Codable {

    public var key = "kern"
    public let kern: Float

    public init(kern: Float = 0) {
        self.kern = kern
    }

    public func apply(to attrStr: NSMutableAttributedString, withRange range: NSRange) {
        attrStr.addAttribute(.kern, value: kern, range: range)
    }
}
