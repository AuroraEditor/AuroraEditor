//
//  TextBlockThemeAttribute.swift
//  Aurora Editor
//
//  Created by Matthew Davidson on 29/12/19.
//  Copyright © 2023 Aurora Company. All rights reserved.
//

import Foundation

import AppKit

public class TextBlockThemeAttribute: LineThemeAttribute, Codable {

    public let key = "text-block"
    public let textBlock: NSTextBlock

    public init(textBlock: NSTextBlock) {
        self.textBlock = textBlock
    }

    public func apply(to style: NSMutableParagraphStyle) {
        style.textBlocks = [self.textBlock]
    }

    public func encode(to encoder: Encoder) throws {
        fatalError("TextBlockThemeAttribute does not conform to Codable as NSTextBlock is a weird class")
    }

    public required init(from decoder: Decoder) throws {
        fatalError("TextBlockThemeAttribute does not conform to Codable as NSTextBlock is a weird class")
    }
}
