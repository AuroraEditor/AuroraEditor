//
//  ParagraphSpacingBeforeThemeAttribute.swift
//  
//
//  Created by Matthew Davidson on 4/12/19.
//

import Foundation

import Cocoa

public class ParagraphSpacingBeforeThemeAttribute: LineThemeAttribute {

    public let key = "para-spacing-before"
    public let spacing: CGFloat

    public init(spacing: CGFloat) {
        self.spacing = spacing
    }

    public func apply(to style: MutableParagraphStyle) {
        style.paragraphSpacingBefore = spacing
    }
}
