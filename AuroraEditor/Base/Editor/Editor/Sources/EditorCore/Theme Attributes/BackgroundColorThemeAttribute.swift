//
//  BackgroundColorThemeAttribute.swift
//  
//
//  Created by Matthew Davidson on 6/12/19.
//

import Foundation
import EditorCore
import Cocoa

public class BackgroundColorThemeAttribute: TokenThemeAttribute {

    public struct RoundingStyle: Hashable, Equatable, RawRepresentable {

        public let rawValue: CGFloat

        public init(rawValue: CGFloat) {
            self.rawValue = rawValue
        }

        public init(_ rawValue: CGFloat) {
            self.rawValue = rawValue
        }

        public static let none = RoundingStyle(0)
        public static let full = RoundingStyle(1)
        public static let half = RoundingStyle(0.5)
        public static let quarter = RoundingStyle(0.25)
    }

    public enum ColoringStyle {

        case line, textOnly
    }

    public class RoundedBackground {

        public static let Key = NSAttributedString.Key(rawValue: "EditorUI.RoundedBackgroundColor")

        public let color: Color
        public let roundingStyle: RoundingStyle
        public let coloringStyle: ColoringStyle

        public init(color: Color, roundingStyle: RoundingStyle, coloringStyle: ColoringStyle) {
            self.color = color
            self.roundingStyle = roundingStyle
            self.coloringStyle = coloringStyle
        }
    }

    public var key = "background-color"
    public var color: Color
    public var roundingStyle: RoundingStyle
    public var coloringStyle: ColoringStyle
    public let roundedBackground: RoundedBackground

    public init(color: Color, roundingStyle: RoundingStyle = .none, coloringStyle: ColoringStyle = .textOnly) {
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
}
