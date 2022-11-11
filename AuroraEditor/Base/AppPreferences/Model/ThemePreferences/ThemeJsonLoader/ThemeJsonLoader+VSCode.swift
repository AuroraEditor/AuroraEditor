//
//  ThemeJsonLoader+VSCode.swift
//  AuroraEditor
//
//  Created by TAY KAI QUAN on 16/10/22.
//  Copyright © 2022 Aurora Company. All rights reserved.
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
            Log.info("Error loading theme: \(String(describing: error))")
        }

        return nil
    }

    public func themeFromVscJson(jsonStr: String) -> AuroraTheme? {
        guard let jsonData = jsonStr.data(using: .utf8),
              let json = try? JSONSerialization.jsonObject(with: jsonData, options: []) as? [String: Any]
        else {
            Log.info("Failed to load vsc json")
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
        Log.info("Selection Color: \(editor.selection.color)")

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
        let text = json["editor.foreground"]
        let insertionPoint = json["editorCursor.foreground"]
        let invisibles = json["editorWhitespace.foreground"]
        let background = json["editor.background"]
        let lineHighlight = json["editor.lineHighlightBackground"]
        let selection = json["editor.selectionHighlightBackground"]

        Log.info("Selection: \(String(describing: selection))")

        let defaultAttr = type == "light" ? AuroraTheme.EditorColors.defaultLight :
        AuroraTheme.EditorColors.defaultDark

        return AuroraTheme.EditorColors(text: text != nil ? Attributes(color: text!) :
                                            defaultAttr.text,
                                        insertionPoint: insertionPoint != nil ? Attributes(color: insertionPoint!) :
                                            defaultAttr.insertionPoint,
                                        invisibles: invisibles != nil ? Attributes(color: invisibles!) :
                                            defaultAttr.invisibles,
                                        background: background != nil ? Attributes(color: background!) :
                                            defaultAttr.background,
                                        lineHighlight: lineHighlight != nil ? Attributes(color: lineHighlight!) :
                                            defaultAttr.lineHighlight,
                                        selection: selection != nil ? Attributes(color: selection!) :
                                            defaultAttr.selection,
                                        highlightTheme: highlightTheme)
    }
}
