//
//  FirstLineHeadIndentThemeAttribute.swift
//  
//
//  Created by Matthew Davidson on 16/12/19.
//

import Foundation

import Cocoa

public class FirstLineHeadIndentThemeAttribute: LineThemeAttribute, Codable {

    public let key = "first-line-head-indent"
    public let value: CGFloat

    public init(value: CGFloat = 0) {
        self.value = value
    }

    public func apply(to style: MutableParagraphStyle) {
        style.firstLineHeadIndent = value
    }
}
