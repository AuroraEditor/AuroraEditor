//
//  DefaultTabIntervalThemeAttribute.swift
//  
//
//  Created by Matthew Davidson on 30/12/19.
//

import Foundation
import EditorCore
#if os(iOS)
import UIKit
#elseif os(macOS)
import Cocoa
#endif

public class DefaultTabIntervalThemeAttribute: LineThemeAttribute {

    public let key = "default-tab-interval"
    public let interval: CGFloat

    public init(interval: CGFloat) {
        self.interval = interval
    }

    public func apply(to style: MutableParagraphStyle) {
        style.defaultTabInterval = interval
    }
}
