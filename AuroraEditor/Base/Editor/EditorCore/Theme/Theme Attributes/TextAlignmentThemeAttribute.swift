//
//  TextAlignmentThemeAttribute.swift
//  Aurora Editor
//
//  Created by Matthew Davidson on 16/12/19.
//  Copyright © 2023 Aurora Company. All rights reserved.
//

import Foundation

import Cocoa

public class TextAlignmentThemeAttribute: LineThemeAttribute, Codable {

    public let key = "first-line-head-indent"
    public let value: NSTextAlignment

    public init(value: NSTextAlignment = .natural) {
        self.value = value
    }

    public func apply(to style: NSMutableParagraphStyle) {
        style.alignment = value
    }

    enum Keys: CodingKey {
        case value
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: Keys.self)
        try container.encode(value.rawValue, forKey: .value)
    }

    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: Keys.self)
        self.value = NSTextAlignment(rawValue: try container.decode(Int.self, forKey: .value))!
    }
}
