//
//  TabStopsThemeAttribute.swift
//  
//
//  Created by Matthew Davidson on 9/1/20.
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

    public func apply(to style: MutableParagraphStyle) {
        style.tabStops = tabStops
    }
}
