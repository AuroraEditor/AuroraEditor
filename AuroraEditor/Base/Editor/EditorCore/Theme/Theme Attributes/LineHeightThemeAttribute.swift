//
//  LineHeightThemeAttribute.swift
//  Aurora Editor
//
//  Created by Matthew Davidson on 16/12/19.
//  Copyright © 2023 Aurora Company. All rights reserved.
//

import Foundation

import Cocoa

public class LineHeightThemeAttribute: LineThemeAttribute, Codable {

    public let key = "line-height"
    public let min: CGFloat
    public let max: CGFloat

    public init(min: CGFloat = 0, max: CGFloat = 0) {
        self.min = min
        self.max = max
    }

    public func apply(to style: NSMutableParagraphStyle) {
        style.minimumLineHeight = min
        style.maximumLineHeight = max
    }
}
