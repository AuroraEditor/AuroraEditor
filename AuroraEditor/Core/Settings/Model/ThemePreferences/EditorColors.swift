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
            lhs.selection == rhs.selection &&
            lhs.keywords == rhs.keywords &&
            lhs.commands == rhs.commands &&
            lhs.types == rhs.types &&
            lhs.attributes == rhs.attributes &&
            lhs.variables == rhs.variables &&
            lhs.values == rhs.values &&
            lhs.numbers == rhs.numbers &&
            lhs.strings == rhs.strings &&
            lhs.characters == rhs.characters &&
            lhs.comments == rhs.comments
        }

        /// Hashable implementation
        public func hash(into hasher: inout Hasher) {
            hasher.combine(text)
            hasher.combine(insertionPoint)
            hasher.combine(background)
            hasher.combine(lineHighlight)
            hasher.combine(selection)
            hasher.combine(keywords)
            hasher.combine(commands)
            hasher.combine(types)
            hasher.combine(attributes)
            hasher.combine(variables)
            hasher.combine(values)
            hasher.combine(numbers)
            hasher.combine(strings)
            hasher.combine(characters)
            hasher.combine(comments)
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
        public var keywords: Attributes
        public var commands: Attributes
        public var types: Attributes
        public var attributes: Attributes
        public var variables: Attributes
        public var values: Attributes
        public var numbers: Attributes
        public var strings: Attributes
        public var characters: Attributes
        public var comments: Attributes

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
                case "keywords":    return self.keywords
                case "commands":    return self.commands
                case "types":       return self.types
                case "attributes":  return self.attributes
                case "variables":   return self.variables
                case "values":      return self.values
                case "numbers":     return self.numbers
                case "strings":     return self.strings
                case "characters":  return self.characters
                case "comments":    return self.comments
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
                case "keywords":    self.keywords = newValue
                case "commands":    self.commands = newValue
                case "types":        self.types = newValue
                case "attributes":  self.attributes = newValue
                case "variables":   self.variables = newValue
                case "values":      self.values = newValue
                case "numbers":     self.numbers = newValue
                case "strings":     self.strings = newValue
                case "characters":  self.characters = newValue
                case "comments":    self.comments = newValue
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
            keywords: Attributes,
            commands: Attributes,
            types: Attributes,
            attributes: Attributes,
            variables: Attributes,
            values: Attributes,
            numbers: Attributes,
            strings: Attributes,
            characters: Attributes,
            comments: Attributes,
            highlightTheme: HighlightTheme
        ) {
            self.text = text
            self.insertionPoint = insertionPoint
            self.invisibles = invisibles
            self.background = background
            self.lineHighlight = lineHighlight
            self.selection = selection
            self.keywords = keywords
            self.commands = commands
            self.types = types
            self.attributes = attributes
            self.variables = variables
            self.values = values
            self.numbers = numbers
            self.strings = strings
            self.characters = characters
            self.comments = comments
            self.highlightTheme = highlightTheme
        }

        /// Encode the editor colors
        enum Keys: CodingKey {
            case text, insertionPoint, invisibles, background, lineHighlight, selection
            case keywords
            case commands
            case types
            case attributes
            case variables
            case values
            case numbers
            case strings
            case characters
            case comments
            case highlightTheme
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
            try container.encode(self.keywords, forKey: .keywords)
            try container.encode(self.commands, forKey: .commands)
            try container.encode(self.types, forKey: .types)
            try container.encode(self.attributes, forKey: .attributes)
            try container.encode(self.variables, forKey: .variables)
            try container.encode(self.values, forKey: .values)
            try container.encode(self.numbers, forKey: .numbers)
            try container.encode(self.strings, forKey: .strings)
            try container.encode(self.characters, forKey: .characters)
            try container.encode(self.comments, forKey: .comments)
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
            self.keywords = try container.decode(Attributes.self, forKey: .keywords)
            self.commands = try container.decode(Attributes.self, forKey: .commands)
            self.types = try container.decode(Attributes.self, forKey: .types)
            self.attributes = try container.decode(Attributes.self, forKey: .attributes)
            self.variables = try container.decode(Attributes.self, forKey: .variables)
            self.values = try container.decode(Attributes.self, forKey: .values)
            self.numbers = try container.decode(Attributes.self, forKey: .numbers)
            self.strings = try container.decode(Attributes.self, forKey: .strings)
            self.characters = try container.decode(Attributes.self, forKey: .characters)
            self.comments = try container.decode(Attributes.self, forKey: .comments)
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
            keywords: Attributes(color: "#FF7AB3"),
            commands: Attributes(color: "#67B7A4"),
            types: Attributes(color: "#5DD8FF"),
            attributes: Attributes(color: "#D0A8FF"),
            variables: Attributes(color: "#41A1C0"),
            values: Attributes(color: "#A167E6"),
            numbers: Attributes(color: "#D0BF69"),
            strings: Attributes(color: "#FC6A5D"),
            characters: Attributes(color: "#D0BF69"),
            comments: Attributes(color: "#73A74E"),
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
            keywords: Attributes(color: "#9B2393"),
            commands: Attributes(color: "#326D74"),
            types: Attributes(color: "#0B4F79"),
            attributes: Attributes(color: "#3900A0"),
            variables: Attributes(color: "#0F68A0"),
            values: Attributes(color: "#6C36A9"),
            numbers: Attributes(color: "#1C00CF"),
            strings: Attributes(color: "#C41A16"),
            characters: Attributes(color: "#1C00CF"),
            comments: Attributes(color: "#267507"),
            highlightTheme: .default
        )
    }
}
