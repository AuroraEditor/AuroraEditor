//
//  TailIndentThemeAttribute.swift
//  Aurora Editor
//
//  Created by Matthew Davidson on 16/12/19.
//  Copyright © 2023 Aurora Company. All rights reserved.
//

import Foundation

import Cocoa

public class TailIndentThemeAttribute: LineThemeAttribute, Codable {

    public let key = "tail-indent"
    public let value: CGFloat

    public init(value: CGFloat = 0) {
        self.value = value
    }

    public func apply(to style: NSMutableParagraphStyle) {
        style.tailIndent = value
    }
}
