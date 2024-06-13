//
//  EditorColors.swift
//  Aurora Editor
//
//  Created by TAY KAI QUAN on 4/10/22.
//  Copyright © 2023 Aurora Company. All rights reserved.
//

import SwiftUI

public extension AuroraTheme {
    /// The editor colors of the theme
    struct EditorColors: Codable, Hashable, Loopable {
        /// Equatable implementation
        /// 
        /// - Parameter lhs: The left-hand side of the comparison
        /// - Parameter rhs: The right-hand side of the comparison
        public static func == (lhs: AuroraTheme.EditorColors, rhs: AuroraTheme.EditorColors) -> Bool {
            lhs.text == rhs.text &&
            lhs.insertionPoint == rhs.insertionPoint &&
            lhs.background == rhs.background &&
            lhs.lineHighlight == rhs.lineHighlight &&
            lhs.selection == rhs.selection
        }

        /// Hashable implementation
        public func hash(into hasher: inout Hasher) {
            hasher.combine(text)
            hasher.combine(insertionPoint)
            hasher.combine(background)
            hasher.combine(lineHighlight)
            hasher.combine(selection)
        }

        /// text color
        public var text: Attributes

        /// cursor color
        public var insertionPoint: Attributes

        /// invisibles color
        public var invisibles: Attributes

        /// backgroundColor
        public var background: Attributes

        /// currentLineColor
        public var lineHighlight: Attributes

        /// selectionColor
        public var selection: Attributes

        /// The highlight theme
        public var highlightTheme: HighlightTheme

        /// Allows to look up properties by their name
        ///
        /// **Example:**
        /// ```swift
        /// editor["text"]
        /// // equal to calling
        /// editor.text
        /// ```
        /// 
        /// - Parameter key: The key to look up
        subscript(key: String) -> Attributes {
            get {
                switch key {
                case "text": return self.text
                case "insertionPoint": return self.insertionPoint
                case "invisibles": return self.invisibles
                case "background": return self.background
                case "lineHighlight": return self.lineHighlight
                case "selection": return self.selection
                default: fatalError("Invalid key")
                }
            }
            set {
                switch key {
                case "text": self.text = newValue
                case "insertionPoint": self.insertionPoint = newValue
                case "invisibles": self.invisibles = newValue
                case "background": self.background = newValue
                case "lineHighlight": self.lineHighlight = newValue
                case "selection": self.selection = newValue
                default: fatalError("Invalid key")
                }
            }
        }

        /// Initialize the editor colors
        /// 
        /// - Parameter text: text color
        /// - Parameter insertionPoint: cursor color
        /// - Parameter invisibles: invisibles color
        /// - Parameter background: backgroundColor
        /// - Parameter lineHighlight: currentLineColor
        /// - Parameter selection: selectionColor
        /// - Parameter highlightTheme: The highlight theme
        public init(
            text: Attributes,
            insertionPoint: Attributes,
            invisibles: Attributes,
            background: Attributes,
            lineHighlight: Attributes,
            selection: Attributes,
            highlightTheme: HighlightTheme
        ) {
            self.text = text
            self.insertionPoint = insertionPoint
            self.invisibles = invisibles
            self.background = background
            self.lineHighlight = lineHighlight
            self.selection = selection
            self.highlightTheme = highlightTheme
        }

        /// Encode the editor colors
        enum Keys: CodingKey {
            case text, insertionPoint, invisibles, background, lineHighlight, selection, highlightTheme
        }

        /// Encode the editor colors
        /// 
        /// - Parameter encoder: The encoder
        public func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: Keys.self)
            try container.encode(self.text, forKey: .text)
            try container.encode(self.insertionPoint, forKey: .insertionPoint)
            try container.encode(self.invisibles, forKey: .invisibles)
            try container.encode(self.background, forKey: .background)
            try container.encode(self.lineHighlight, forKey: .lineHighlight)
            try container.encode(self.selection, forKey: .selection)
            try container.encode(self.highlightTheme, forKey: .highlightTheme)
        }

        /// Decode the editor colors
        /// 
        /// - Parameter decoder: The decoder
        public init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: Keys.self)

            self.text = try container.decode(Attributes.self, forKey: .text)
            self.insertionPoint = try container.decode(Attributes.self, forKey: .insertionPoint)
            self.invisibles = try container.decode(Attributes.self, forKey: .invisibles)
            self.background = try container.decode(Attributes.self, forKey: .background)
            self.lineHighlight = try container.decode(Attributes.self, forKey: .lineHighlight)
            self.selection = try container.decode(Attributes.self, forKey: .selection)
            self.highlightTheme = (try? container.decode(HighlightTheme.self, forKey: .highlightTheme)) ?? .default
        }

        /// Default dark theme
        public static let defaultDark: EditorColors = .init(
            text: Attributes(color: "#D9D9D9"),
            insertionPoint: Attributes(color: "#D9D9D9"),
            invisibles: Attributes(color: "#53606e"),
            background: Attributes(color: "#292a30"),
            lineHighlight: Attributes(color: "#2f3239"),
            selection: Attributes(color: "#636f83"),
            highlightTheme: .default
        )

        /// Default light theme
        public static let defaultLight: EditorColors = .init(
            text: Attributes(color: "#262626"),
            insertionPoint: Attributes(color: "#262626"),
            invisibles: Attributes(color: "#d6d6d6"),
            background: Attributes(color: "#FFFFFF"),
            lineHighlight: Attributes(color: "#ecf5ff"),
            selection: Attributes(color: "#b2d7ff"),
            highlightTheme: .default
        )
    }
}
