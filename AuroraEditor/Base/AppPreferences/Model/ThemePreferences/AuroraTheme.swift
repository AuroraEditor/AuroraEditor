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

    enum Keys: String, CodingKey {
        case author, license, distributionURL, name, displayName, editor, terminal, version
        case fontName, fontSize
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

    public var fontName: String = "SFMono-Medium"

    public var fontSize: CGFloat = 13.0

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
        version: String,
        fontName: String = "SFMono-Medium",
        fontSize: CGFloat = 13.0
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
        self.fontName = fontName
        self.fontSize = fontSize
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: Keys.self)
        try container.encode(author, forKey: .author)
        try container.encode(license, forKey: .license)
        try container.encode(distributionURL, forKey: .distributionURL)
        try container.encode(name, forKey: .name)
        try container.encode(displayName, forKey: .displayName)
        try container.encode(editor, forKey: .editor)
        try container.encode(terminal, forKey: .terminal)
        try container.encode(version, forKey: .version)
        try container.encode(fontName, forKey: .fontName)
        try container.encode(fontSize, forKey: .fontSize)
        try container.encode(appearance, forKey: .appearance)
        try container.encode(metadataDescription, forKey: .metadataDescription)
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: Keys.self)
        self.author = try container.decode(String.self, forKey: .author)
        self.license = try container.decode(String.self, forKey: .license)
        self.distributionURL = try container.decode(String.self, forKey: .distributionURL)
        self.name = try container.decode(String.self, forKey: .name)
        self.displayName = try container.decode(String.self, forKey: .displayName)
        self.editor = try container.decode(EditorColors.self, forKey: .editor)
        self.terminal = try container.decode(TerminalColors.self, forKey: .terminal)
        self.version = try container.decode(String.self, forKey: .version)
        self.appearance = try container.decode(ThemeType.self, forKey: .appearance)
        self.metadataDescription = try container.decode(String.self, forKey: .metadataDescription)
        if let fontName = try? container.decode(String.self, forKey: .fontName) { self.fontName = fontName }
        if let fontSize = try? container.decode(CGFloat.self, forKey: .fontSize) { self.fontSize = fontSize }
    }

    public var font: NSFont {
        if fontName.hasPrefix("SFMono") {

            let weightString = fontName.dropFirst("SFMono".count)
            let weight: NSFont.Weight
            switch weightString {
            case "UltraLight": weight = .ultraLight
            case "Thin":       weight = .thin
            case "Light":      weight = .light
            case "Regular":    weight = .regular
            case "Medium":     weight = .medium
            case "Semibold":   weight = .semibold
            case "Bold":       weight = .bold
            case "Heavy":      weight = .heavy
            case "Black":      weight = .black
            default:           weight = .regular
            }
            return NSFont.monospacedSystemFont(ofSize: fontSize, weight: weight)

        } else {

            return NSFont(name: fontName, size: fontSize) ?? OSFont.monospacedSystemFont(ofSize: fontSize,
                                                                                         weight: .regular)

        }
    }
}

public extension AuroraTheme {
    /// The type of the theme
    /// - **dark**: this is a theme for dark system appearance
    /// - **light**: this is a theme for light system appearance
    /// - **universal**: this is a theme for all system appearances
    enum ThemeType: String, Codable, Hashable {
        case dark
        case light
        case universal
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

        public internal(set) var nsColor: NSColor {
            get {
                NSColor(hex: color)
            }
            set {
                self.color = newValue.hexString
            }
        }
    }
}
