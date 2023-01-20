//
//  ParagraphSpacingAfterThemeAttribute.swift
//  Aurora Editor
//
//  Created by Matthew Davidson on 4/12/19.
//

import Foundation

import Cocoa

public class ParagraphSpacingAfterThemeAttribute: LineThemeAttribute, Codable {

    public let key = "para-spacing-after"
    public let spacing: CGFloat

    public init(spacing: CGFloat) {
        self.spacing = spacing
    }

    public func apply(to style: NSMutableParagraphStyle) {
        style.paragraphSpacing = spacing
    }
}
