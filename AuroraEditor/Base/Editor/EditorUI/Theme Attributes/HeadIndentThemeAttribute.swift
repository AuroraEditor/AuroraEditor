//
//  HeadIndentThemeAttribute.swift
//  
//
//  Created by Matthew Davidson on 16/12/19.
//

import Foundation
import EditorCore
import Cocoa

public class HeadIndentThemeAttribute: LineThemeAttribute {

    public let key = "head-indent"
    public let value: CGFloat

    public init(value: CGFloat = 0) {
        self.value = value
    }

    public func apply(to style: MutableParagraphStyle) {
        style.headIndent = value
    }
}