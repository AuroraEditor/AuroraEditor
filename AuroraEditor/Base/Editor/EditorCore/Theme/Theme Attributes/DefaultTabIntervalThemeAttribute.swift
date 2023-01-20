//
//  DefaultTabIntervalThemeAttribute.swift
//  Aurora Editor
//
//  Created by Matthew Davidson on 30/12/19.
//

import Foundation

import Cocoa

public class DefaultTabIntervalThemeAttribute: LineThemeAttribute, Codable {

    public let key = "default-tab-interval"
    public let interval: CGFloat

    public init(interval: CGFloat) {
        self.interval = interval
    }

    public func apply(to style: NSMutableParagraphStyle) {
        style.defaultTabInterval = interval
    }
}
