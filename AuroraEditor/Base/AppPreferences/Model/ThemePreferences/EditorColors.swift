//
//  EditorColors.swift
//  AuroraEditor
//
//  Created by TAY KAI QUAN on 4/10/22.
//  Copyright © 2022 Aurora Company. All rights reserved.
//

import SwiftUI

public extension AuroraTheme {
    /// The editor colors of the theme
    struct EditorColors: Codable, Hashable, Loopable {
        public static func == (lhs: AuroraTheme.EditorColors, rhs: AuroraTheme.EditorColors) -> Bool {
            lhs.text == rhs.text &&
            lhs.insertionPoint == rhs.insertionPoint &&
            lhs.background == rhs.background &&
            lhs.lineHighlight == rhs.lineHighlight &&
            lhs.selection == rhs.selection &&
            lhs.highlightTheme.name == rhs.highlightTheme.name
        }

        public func hash(into hasher: inout Hasher) {
            hasher.combine(text)
            hasher.combine(insertionPoint)
            hasher.combine(background)
            hasher.combine(lineHighlight)
            hasher.combine(selection)
            hasher.combine(highlightTheme.name)
        }

        public var text: Attributes                 // textColor
        public var insertionPoint: Attributes       // cursorColor
        public var invisibles: Attributes           // invisiblesColor
        public var background: Attributes           // backgroundColor
        public var lineHighlight: Attributes        // currentLineColor
        public var selection: Attributes            // selectionColor
        public var highlightTheme: HighlightTheme

        /// Allows to look up properties by their name
        ///
        /// **Example:**
        /// ```swift
        /// editor["text"]
        /// // equal to calling
        /// editor.text
        /// ```
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

        enum Keys: CodingKey {
            case text, insertionPoint, invisibles, background, lineHighlight, selection, highlightTheme
        }

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
    }
}
