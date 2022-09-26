//
//  ParagraphSpacingAfterThemeAttribute.swift
//  
//
//  Created by Matthew Davidson on 4/12/19.
//

import Foundation
import EditorCore
import Cocoa

public class ParagraphSpacingAfterThemeAttribute: LineThemeAttribute {

    public let key = "para-spacing-after"
    public let spacing: CGFloat

    public init(spacing: CGFloat) {
        self.spacing = spacing
    }

    public func apply(to style: MutableParagraphStyle) {
        style.paragraphSpacing = spacing
    }
}
