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
