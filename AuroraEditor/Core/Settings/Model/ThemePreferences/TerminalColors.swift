//
//  TerminalColors.swift
//  Aurora Editor
//
//  Created by TAY KAI QUAN on 4/10/22.
//  Copyright © 2023 Aurora Company. All rights reserved.
//

import SwiftUI

public extension AuroraTheme {
    /// The terminal emulator colors of the theme
    struct TerminalColors: Codable, Hashable, Loopable {
        /// Text color
        public var text: Attributes

        /// Bold text color
        public var boldText: Attributes

        /// Cursor color
        public var cursor: Attributes

        /// Background color
        public var background: Attributes

        /// Selection color
        public var selection: Attributes

        /// Black color
        public var black: Attributes

        /// Red color
        public var red: Attributes

        /// Green color
        public var green: Attributes

        /// Yellow color
        public var yellow: Attributes

        /// Blue color
        public var blue: Attributes

        /// Magenta color
        public var magenta: Attributes

        /// Cyan color
        public var cyan: Attributes

        /// White color
        public var white: Attributes

        /// Bright black color
        public var brightBlack: Attributes

        /// Bright red color
        public var brightRed: Attributes

        /// Bright green color
        public var brightGreen: Attributes

        /// Bright yellow color
        public var brightYellow: Attributes

        /// Bright blue color
        public var brightBlue: Attributes

        /// Bright magenta color
        public var brightMagenta: Attributes

        /// Bright cyan color
        public var brightCyan: Attributes

        /// Bright white color
        public var brightWhite: Attributes

        /// The ANSI colors in order
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
        /// 
        /// - Parameter key: The key to look up
        subscript(key: String) -> Attributes {
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

        /// Initialize the terminal colors
        /// 
        /// - Parameter text: text color
        /// - Parameter boldText: bold text color
        /// - Parameter cursor: cursor color
        /// - Parameter background: backgroundColor
        /// - Parameter selection: selectionColor
        /// - Parameter black: black color
        /// - Parameter red: red color
        /// - Parameter green: green color
        /// - Parameter yellow: yellow color
        /// - Parameter blue: blue color
        /// - Parameter magenta: magenta color
        /// - Parameter cyan: cyan color
        /// - Parameter white: white color
        /// - Parameter brightBlack: bright black color
        /// - Parameter brightRed: bright red color
        /// - Parameter brightGreen: bright green color
        /// - Parameter brightYellow: bright yellow color
        /// - Parameter brightBlue: bright blue color
        /// - Parameter brightMagenta: bright magenta color
        /// - Parameter brightCyan: bright cyan color
        /// - Parameter brightWhite: bright white color
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

        /// Default dark colors
        nonisolated(unsafe) public static let defaultDark: TerminalColors = .init(
            text: Attributes(color: "#d9d9d9"),
            boldText: Attributes(color: "#d9d9d9"),
            cursor: Attributes(color: "#d9d9d9"),
            background: Attributes(color: "#1f2024"),
            selection: Attributes(color: "#515b70"),
            black: Attributes(color: "#1f2024"),
            red: Attributes(color: "#ff3b30"),
            green: Attributes(color: "#28cd41"),
            yellow: Attributes(color: "#ffcc00"),
            blue: Attributes(color: "#007aff"),
            magenta: Attributes(color: "#af52de"),
            cyan: Attributes(color: "#59adc4"),
            white: Attributes(color: "#d9d9d9"),
            brightBlack: Attributes(color: "#8e8e93"),
            brightRed: Attributes(color: "#ff3b30"),
            brightGreen: Attributes(color: "#28cd41"),
            brightYellow: Attributes(color: "#ffff00"),
            brightBlue: Attributes(color: "#007aff"),
            brightMagenta: Attributes(color: "#af52de"),
            brightCyan: Attributes(color: "#55bef0"),
            brightWhite: Attributes(color: "#ffffff")
        )

        /// Default light colors
        nonisolated(unsafe) public static let defaultLight: TerminalColors = .init(
            text: Attributes(color: "#262626"),
            boldText: Attributes(color: "#262626"),
            cursor: Attributes(color: "#262626"),
            background: Attributes(color: "#ffffff"),
            selection: Attributes(color: "#a4cdff"),
            black: Attributes(color: "#1f2024"),
            red: Attributes(color: "#ff3b30"),
            green: Attributes(color: "#28cd41"),
            yellow: Attributes(color: "#ffcc00"),
            blue: Attributes(color: "#007aff"),
            magenta: Attributes(color: "#af52de"),
            cyan: Attributes(color: "#59adc4"),
            white: Attributes(color: "#d9d9d9"),
            brightBlack: Attributes(color: "#8e8e93"),
            brightRed: Attributes(color: "#ff3b30"),
            brightGreen: Attributes(color: "#28cd41"),
            brightYellow: Attributes(color: "#ffcc00"),
            brightBlue: Attributes(color: "#007aff"),
            brightMagenta: Attributes(color: "#af52de"),
            brightCyan: Attributes(color: "#55bef0"),
            brightWhite: Attributes(color: "#ffffff")
        )
    }
}
