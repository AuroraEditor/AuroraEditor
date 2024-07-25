//
//  ThemeJsonLoader+VSCode.swift
//  Aurora Editor
//
//  Created by TAY KAI QUAN on 16/10/22.
//  Copyright © 2023 Aurora Company. All rights reserved.
//

import SwiftUI

extension ThemeJsonLoader {

    /// Function that, taking in a URL for a vscode theme JSON file,
    /// returns an ``AuroraTheme`` from its contents
    /// - Parameter url: The URL of the JSON file
    /// - Returns: An ``AuroraTheme`` representing the contents of the JSON, or
    /// nil if the given URL cannot be read as a grammar json.
    public func loadVscJson(from url: URL) -> AuroraTheme? {

        do {
            let data = try Data(contentsOf: url)
            return themeFromVscJson(jsonStr: String(decoding: data, as: UTF8.self))
        } catch {
            self.logger.info("Error loading theme: \(String(describing: error))")
        }

        return nil
    }

    /// Theme from Visual Studio Code JSON
    /// - Parameter jsonStr: JSON String
    /// - Returns: AuroraTheme
    public func themeFromVscJson(jsonStr: String) -> AuroraTheme? {
        guard let jsonData = jsonStr.data(using: .utf8),
              let json = try? JSONSerialization.jsonObject(with: jsonData, options: []) as? [String: Any]
        else {
            self.logger.info("Failed to load vsc json")
            return nil
        }

        // vscode themes need to contain a `name` and a `type`,
        // and optionally a `colors` and `settings` field

        let name = json["name"] as? String
        guard let type = json["type"] as? String,
              type == "light" || type == "dark"
        else { return nil }

        let colors = (json["colors"] as? [String: String]) ?? [:]
        let settings = ((json["settings"] ?? json["tokenColors"]) as? [[String: Any]]) ?? []

        // get the HighlightTheme and EditorColors
        let highlightTheme = highlightThemeFromJson(json: settings)
        let editor = editorFromVscJson(json: colors, highlightTheme: highlightTheme, type: type)
        self.logger.info("Selection Color: \(editor.selection.color)")

        // if the theme does not contain a source, add one
        if !highlightTheme.settings.contains(where: { $0.isSource }) {
            highlightTheme.settings.append(ThemeSetting(scope: "source",
                                                        attributes: [ColorThemeAttribute(color: editor.text.nsColor)]))
        }
        // add the default monospace font to the theme
        // TODO: Allow custom fonts, font sizes, and font weights
        if let sourceIndex = highlightTheme.settings.firstIndex(where: { $0.isSource }) {
            var sourceSetting = highlightTheme.settings.remove(at: sourceIndex)
            sourceSetting.attributes.append(FontThemeAttribute(font: .monospacedSystemFont(ofSize: 13,
                                                                                           weight: .regular)))
            highlightTheme.settings.append(sourceSetting)
        }
        highlightTheme.root = HighlightTheme.createTrie(settings: highlightTheme.settings)

        var appearance = AuroraTheme.ThemeType.universal
        if type == "light" { appearance = .light }
        if type == "dark" { appearance = .dark }

        return AuroraTheme(editor: editor,
                           terminal: type == "light" ? .defaultLight : .defaultDark,
                           author: "Imported via VSCode Theme",
                           license: "Imported via VSCode Theme",
                           metadataDescription: "none",
                           distributionURL: "https://www.youtube.com/watch?v=dQw4w9WgXcQ",
                           name: name ?? "Untitled Theme",
                           displayName: name ?? "Untitled Theme",
                           appearance: appearance,
                           version: "unknown")
    }

    func editorFromVscJson(json: [String: String],
                           highlightTheme: HighlightTheme,
                           type: String) -> AuroraTheme.EditorColors {
        let defaultAttr = type == "light" ? AuroraTheme.EditorColors.defaultLight :
        AuroraTheme.EditorColors.defaultDark

        let text = json["editor.foreground"] ?? defaultAttr.text.color
        let insertionPoint = json["editorCursor.foreground"] ?? defaultAttr.insertionPoint.color
        let invisibles = json["editorWhitespace.foreground"] ?? defaultAttr.invisibles.color
        let background = json["editor.background"] ?? defaultAttr.background.color
        let lineHighlight = json["editor.lineHighlightBackground"] ?? defaultAttr.lineHighlight.color
        let selection = json["editor.selectionHighlightBackground"] ?? defaultAttr.selection.color
        let keywords = defaultAttr.keywords.color
        let commands = defaultAttr.commands.color
        let types = defaultAttr.types.color
        let attributes = defaultAttr.attributes.color
        let variables = defaultAttr.variables.color
        let values = defaultAttr.values.color
        let numbers = defaultAttr.numbers.color
        let strings = defaultAttr.strings.color
        let characters = defaultAttr.characters.color
        let comments = defaultAttr.comments.color

        self.logger.info("Selection: \(String(describing: selection))")

        return AuroraTheme.EditorColors(
            text: Attributes(color: text),
            insertionPoint: Attributes(color: insertionPoint),
            invisibles: Attributes(color: invisibles),
            background: Attributes(color: background),
            lineHighlight: Attributes(color: lineHighlight),
            selection: Attributes(color: selection),
            keywords: Attributes(color: keywords),
            commands: Attributes(color: commands),
            types: Attributes(color: types),
            attributes: Attributes(color: attributes),
            variables: Attributes(color: variables),
            values: Attributes(color: values),
            numbers: Attributes(color: numbers),
            strings: Attributes(color: strings),
            characters: Attributes(color: characters),
            comments: Attributes(color: comments),
            highlightTheme: highlightTheme)
    }
}
