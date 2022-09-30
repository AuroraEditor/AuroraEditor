//
//  AuroraTheme.swift
//  AuroraEditorModules/AppPreferences
//
//  Created by Lukas Pistrol on 31.03.22.
//

import SwiftUI

/// # Theme
///
/// The model structure of themes for the editor & terminal emulator
public struct AuroraTheme: Identifiable, Codable, Equatable, Hashable, Loopable {

    enum CodingKeys: String, CodingKey {
        case author, license, distributionURL, name, displayName, editor, terminal, version
        case appearance = "type"
        case metadataDescription = "description"
    }

    public static func == (lhs: AuroraTheme, rhs: AuroraTheme) -> Bool {
        lhs.id == rhs.id
    }

    /// The `id` of the theme
    public var id: String { self.name }

    /// The `author` of the theme
    public var author: String

    /// The `licence` of the theme
    public var license: String

    /// A short `description` of the theme
    public var metadataDescription: String

    /// An URL for reference
    public var distributionURL: String

    /// The `unique name` of the theme
    public var name: String

    /// The `display name` of the theme
    public var displayName: String

    /// The `version` of the theme
    public var version: String

    /// The ``ThemeType`` of the theme
    ///
    /// Appears as `"type"` in the `preferences.json`
    public var appearance: ThemeType

    /// Editor colors of the theme
    public var editor: EditorColors

    /// Terminal colors of the theme
    public var terminal: TerminalColors

    public init(
        editor: EditorColors,
        terminal: TerminalColors,
        author: String,
        license: String,
        metadataDescription: String,
        distributionURL: String,
        name: String,
        displayName: String,
        appearance: ThemeType,
        version: String
    ) {
        self.author = author
        self.license = license
        self.metadataDescription = metadataDescription
        self.distributionURL = distributionURL
        self.name = name
        self.displayName = displayName
        self.appearance = appearance
        self.version = version
        self.editor = editor
        self.terminal = terminal
    }
}

public extension AuroraTheme {
    /// The type of the theme
    /// - **dark**: this is a theme for dark system appearance
    /// - **light**: this is a theme for light system appearance
    enum ThemeType: String, Codable, Hashable {
        case dark
        case light
    }
}

// MARK: - Attributes
public extension AuroraTheme {
    /// Attributes of a certain field
    ///
    /// As of now it only includes the colors `hex` string and
    /// an accessor for a `SwiftUI` `Color`.
    struct Attributes: Codable, Equatable, Hashable, Loopable {

        /// The 24-bit hex string of the color (e.g. #123456)
        public var color: String

        public init(color: String) {
            self.color = color
        }

        /// The `SwiftUI` color
        public internal(set) var swiftColor: Color {
            get {
                Color(hex: color)
            }
            set {
                self.color = newValue.hexString
            }
        }
    }
}

public extension AuroraTheme {
    /// The editor colors of the theme
    struct EditorColors: Codable, Hashable, Loopable {
        public var text: Attributes
        public var insertionPoint: Attributes
        public var background: Attributes
        public var lineHighlight: Attributes
        public var selection: Attributes
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
            background: Attributes,
            lineHighlight: Attributes,
            selection: Attributes,
            highlightTheme: HighlightTheme
        ) {
            self.text = text
            self.insertionPoint = insertionPoint
            self.background = background
            self.lineHighlight = lineHighlight
            self.selection = selection
            self.highlightTheme = highlightTheme
        }
    }
}

public extension AuroraTheme {
    /// The terminal emulator colors of the theme
    struct TerminalColors: Codable, Hashable, Loopable {
        public var text: Attributes
        public var boldText: Attributes
        public var cursor: Attributes
        public var background: Attributes
        public var selection: Attributes
        public var black: Attributes
        public var red: Attributes
        public var green: Attributes
        public var yellow: Attributes
        public var blue: Attributes
        public var magenta: Attributes
        public var cyan: Attributes
        public var white: Attributes
        public var brightBlack: Attributes
        public var brightRed: Attributes
        public var brightGreen: Attributes
        public var brightYellow: Attributes
        public var brightBlue: Attributes
        public var brightMagenta: Attributes
        public var brightCyan: Attributes
        public var brightWhite: Attributes

        public var ansiColors: [String] {
            [
                black.color,
                red.color,
                green.color,
                yellow.color,
                blue.color,
                magenta.color,
                cyan.color,
                white.color,
                brightBlack.color,
                brightRed.color,
                brightGreen.color,
                brightYellow.color,
                brightBlue.color,
                brightMagenta.color,
                brightCyan.color,
                brightWhite.color
            ]
        }

        /// Allows to look up properties by their name
        ///
        /// **Example:**
        /// ```swift
        /// terminal["text"]
        /// // equal to calling
        /// terminal.text
        /// ```
        subscript(key: String) -> Attributes { // swiftlint:disable:this function_body_length
            get {
                switch key {
                case "text": return self.text
                case "boldText": return self.boldText
                case "cursor": return self.cursor
                case "background": return self.background
                case "selection": return self.selection
                case "black": return self.black
                case "red": return self.red
                case "green": return self.green
                case "yellow": return self.yellow
                case "blue": return self.blue
                case "magenta": return self.magenta
                case "cyan": return self.cyan
                case "white": return self.white
                case "brightBlack": return self.brightBlack
                case "brightRed": return self.brightRed
                case "brightGreen": return self.brightGreen
                case "brightYellow": return self.brightYellow
                case "brightBlue": return self.brightBlue
                case "brightMagenta": return self.brightMagenta
                case "brightCyan": return self.brightCyan
                case "brightWhite": return self.brightWhite
                default: fatalError("Invalid key")
                }
            }
            set {
                switch key {
                case "text": self.text = newValue
                case "boldText": self.boldText = newValue
                case "cursor": self.cursor = newValue
                case "background": self.background = newValue
                case "selection": self.selection = newValue
                case "black": self.black = newValue
                case "red": self.red = newValue
                case "green": self.green = newValue
                case "yellow": self.yellow = newValue
                case "blue": self.blue = newValue
                case "magenta": self.magenta = newValue
                case "cyan": self.cyan = newValue
                case "white": self.white = newValue
                case "brightBlack": self.brightBlack = newValue
                case "brightRed": self.brightRed = newValue
                case "brightGreen": self.brightGreen = newValue
                case "brightYellow": self.brightYellow = newValue
                case "brightBlue": self.brightBlue = newValue
                case "brightMagenta": self.brightMagenta = newValue
                case "brightCyan": self.brightCyan = newValue
                case "brightWhite": self.brightWhite = newValue
                default: fatalError("Invalid key")
                }
            }
        }

        init(
            text: Attributes,
            boldText: Attributes,
            cursor: Attributes,
            background: Attributes,
            selection: Attributes,
            black: Attributes,
            red: Attributes,
            green: Attributes,
            yellow: Attributes,
            blue: Attributes,
            magenta: Attributes,
            cyan: Attributes,
            white: Attributes,
            brightBlack: Attributes,
            brightRed: Attributes,
            brightGreen: Attributes,
            brightYellow: Attributes,
            brightBlue: Attributes,
            brightMagenta: Attributes,
            brightCyan: Attributes,
            brightWhite: Attributes
        ) {
            self.text = text
            self.boldText = boldText
            self.cursor = cursor
            self.background = background
            self.selection = selection
            self.black = black
            self.red = red
            self.green = green
            self.yellow = yellow
            self.blue = blue
            self.magenta = magenta
            self.cyan = cyan
            self.white = white
            self.brightBlack = brightBlack
            self.brightRed = brightRed
            self.brightGreen = brightGreen
            self.brightYellow = brightYellow
            self.brightBlue = brightBlue
            self.brightMagenta = brightMagenta
            self.brightCyan = brightCyan
            self.brightWhite = brightWhite
        }
    }
}
