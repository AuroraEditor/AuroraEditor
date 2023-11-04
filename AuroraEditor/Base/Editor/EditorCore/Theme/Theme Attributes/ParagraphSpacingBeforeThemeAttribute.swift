//
//  ParagraphSpacingBeforeThemeAttribute.swift
//  Aurora Editor
//
//  Created by Matthew Davidson on 4/12/19.
//  Copyright © 2023 Aurora Company. All rights reserved.
//

import Foundation

import AppKit

public class ParagraphSpacingBeforeThemeAttribute: LineThemeAttribute, Codable {

    public let key = "para-spacing-before"
    public let spacing: CGFloat

    public init(spacing: CGFloat) {
        self.spacing = spacing
    }

    public func apply(to style: NSMutableParagraphStyle) {
        style.paragraphSpacingBefore = spacing
    }
}
