//
//  BackgroundNSColorThemeAttribute.swift
//  Aurora Editor
//
//  Created by Matthew Davidson on 6/12/19.
//  Copyright © 2023 Aurora Company. All rights reserved.
//

import SwiftUI

@available(*, deprecated)
public class BackgroundColorThemeAttribute: TokenThemeAttribute, Codable {

    public struct RoundingStyle: Hashable, Equatable, RawRepresentable {

        public let rawValue: CGFloat

        public init(rawValue: CGFloat) {
            self.rawValue = rawValue
        }

        public init(_ rawValue: CGFloat) {
            self.rawValue = rawValue
        }

        nonisolated(unsafe) public static let none = RoundingStyle(0)
        nonisolated(unsafe) public static let full = RoundingStyle(1)
        nonisolated(unsafe) public static let half = RoundingStyle(0.5)
        nonisolated(unsafe) public static let quarter = RoundingStyle(0.25)
    }

    public enum ColoringStyle {

        case line, textOnly
    }

    public class RoundedBackground: Codable {

        public static let Key = NSAttributedString.Key(rawValue: "EditorUI.RoundedBackgroundNSColor")

        public let color: NSColor
        public let roundingStyle: RoundingStyle
        public let coloringStyle: ColoringStyle

        public init(color: NSColor, roundingStyle: RoundingStyle, coloringStyle: ColoringStyle) {
            self.color = color
            self.roundingStyle = roundingStyle
            self.coloringStyle = coloringStyle
        }

        enum Keys: CodingKey {
            case color, roundingStyle, coloringStyle
        }

        public func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: Keys.self)
            try container.encode(color.hex, forKey: .roundingStyle)
            try container.encode(roundingStyle.rawValue, forKey: .roundingStyle)
            try container.encode(coloringStyle.hashValue, forKey: .roundingStyle)
        }

        public required init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: Keys.self)
            self.color = NSColor(hex: try container.decode(Int.self, forKey: .color))
            self.roundingStyle = RoundingStyle(try container.decode(CGFloat.self, forKey: .roundingStyle))
            self.coloringStyle = (try container.decode(String.self, forKey: .coloringStyle)) == "line" ?
                .line : .textOnly
        }
    }

    public let key = "background-NSColor"
    public var color: NSColor
    public var roundingStyle: RoundingStyle
    public var coloringStyle: ColoringStyle
    public let roundedBackground: RoundedBackground

    public init(color: NSColor, roundingStyle: RoundingStyle = .none, coloringStyle: ColoringStyle = .textOnly) {
        self.color = color
        self.roundingStyle = roundingStyle
        self.coloringStyle = coloringStyle
        self.roundedBackground = RoundedBackground(color: color,
                                                   roundingStyle: roundingStyle,
                                                   coloringStyle: coloringStyle)
    }

    public func apply(to attrStr: NSMutableAttributedString, withRange range: NSRange) {
        if roundingStyle == .none {
            attrStr.addAttribute(.backgroundColor, value: color, range: range)
        } else {
            attrStr.addAttribute(RoundedBackground.Key, value: self.roundedBackground, range: range)
        }
    }

    enum Keys: CodingKey {
        case color, roundingStyle, coloringStyle, roundedBackground
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: Keys.self)
        try container.encode(color.hex, forKey: .color)
        try container.encode(roundingStyle.rawValue, forKey: .roundingStyle)
        try container.encode("\(coloringStyle)", forKey: .coloringStyle)
        try container.encode(roundedBackground, forKey: .roundedBackground)
    }

    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: Keys.self)
        self.color = NSColor(hex: try container.decode(Int.self, forKey: .color))
        self.roundingStyle = RoundingStyle(try container.decode(CGFloat.self, forKey: .roundingStyle))
        self.coloringStyle = (try container.decode(String.self, forKey: .coloringStyle)) == "line" ? .line : .textOnly
        self.roundedBackground = try container.decode(RoundedBackground.self, forKey: .roundedBackground)
    }
}
