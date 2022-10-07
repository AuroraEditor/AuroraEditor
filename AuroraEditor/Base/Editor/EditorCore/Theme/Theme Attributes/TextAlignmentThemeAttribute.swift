//
//  TextAlignmentThemeAttribute.swift
//  
//
//  Created by Matthew Davidson on 16/12/19.
//

import Foundation

import Cocoa

public class TextAlignmentThemeAttribute: LineThemeAttribute {

    public let key = "first-line-head-indent"
    public let value: NSTextAlignment

    public init(value: NSTextAlignment = .natural) {
        self.value = value
    }

    public func apply(to style: MutableParagraphStyle) {
        style.alignment = value
    }
}
