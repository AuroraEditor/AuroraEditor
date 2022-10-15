//
//  TerminalColors.swift
//  AuroraEditor
//
//  Created by TAY KAI QUAN on 4/10/22.
//  Copyright © 2022 Aurora Company. All rights reserved.
//

import SwiftUI

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

        public static let defaultDark: TerminalColors = .init(text: Attributes(color: "#d9d9d9"),
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
                                                              brightWhite: Attributes(color: "#ffffff"))

        public static let defaultLight: TerminalColors = .init(text: Attributes(color: "#262626"),
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
                                                               brightWhite: Attributes(color: "#ffffff"))
    }
}
