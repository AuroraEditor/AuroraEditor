//
//  TabStopsThemeAttribute.swift
//  Aurora Editor
//
//  Created by Matthew Davidson on 9/1/20.
//  Copyright © 2023 Aurora Company. All rights reserved.
//

import Foundation

import Cocoa

public class TabStopsThemeAttribute: LineThemeAttribute {

    public let key = "tab-stops"
    public let tabStops: [NSTextTab]

    public init(tabStops: [NSTextTab] = []) {
        self.tabStops = tabStops
    }

    public init(alignment: NSTextAlignment, locations: [CGFloat]) {
        self.tabStops = locations.map { NSTextTab(textAlignment: alignment, location: $0) }
    }

    public func apply(to style: NSMutableParagraphStyle) {
        style.tabStops = tabStops
    }

    enum Keys: CodingKey {
        case tabStops
    }

    public func encode(to encoder: Encoder) throws {
        fatalError("TabsStopsThemeAttribute does not conform to Codable as NSTextTab is a weird class")
    }

    public required init(from decoder: Decoder) throws {
        fatalError("TabsStopsThemeAttribute does not conform to Codable as NSTextTab is a weird class")
    }
}
