//
//  DefaultTabIntervalThemeAttribute.swift
//  Aurora Editor
//
//  Created by Matthew Davidson on 30/12/19.
//  Copyright © 2023 Aurora Company. All rights reserved.
//

import Foundation

import AppKit

public class DefaultTabIntervalThemeAttribute: LineThemeAttribute, Codable {
    public var key = "default-tab-interval"
    public let interval: CGFloat

    public init(interval: CGFloat) {
        self.interval = interval
    }

    public func apply(to style: NSMutableParagraphStyle) {
        style.defaultTabInterval = interval
    }
}
