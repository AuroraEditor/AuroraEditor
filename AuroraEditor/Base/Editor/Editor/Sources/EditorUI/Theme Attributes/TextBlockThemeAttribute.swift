//
//  TextBlockThemeAttribute.swift
//  
//
//  Created by Matthew Davidson on 29/12/19.
//

import Foundation
import EditorCore

#if os(iOS)
import UIKit
#elseif os(macOS)
import Cocoa

public class TextBlockThemeAttribute: LineThemeAttribute {

    public let key = "text-block"
    public let textBlock: NSTextBlock

    public init(textBlock: NSTextBlock) {
        self.textBlock = textBlock
    }

    public func apply(to style: MutableParagraphStyle) {
        style.textBlocks = [self.textBlock]
    }
}
#endif
