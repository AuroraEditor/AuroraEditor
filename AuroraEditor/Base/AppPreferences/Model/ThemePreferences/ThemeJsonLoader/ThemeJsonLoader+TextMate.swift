//
//  ThemeJsonLoader+TextMate.swift
//  AuroraEditor
//
//  Created by TAY KAI QUAN on 16/10/22.
//  Copyright © 2022 Aurora Company. All rights reserved.
//

import SwiftUI

extension ThemeJsonLoader {

    /// Function that, taking in a URL for a textmate theme XML or Property List file,
    /// returns an ``AuroraTheme`` from its contents
    /// - Parameter url: The URL of the tmtheme file
    /// - Returns: An ``AuroraTheme`` representing the contents of the JSON, or
    /// nil if the given URL cannot be read as a grammar json.
    public func loadTmThemeXml(from url: URL) -> AuroraTheme? {

        do {
            let data = try Data(contentsOf: url)

            // account for the possibility that the .tmTheme is in JSON format, not XML/Plist
            if let jsonData = String(decoding: data, as: UTF8.self).data(using: .utf8),
               let json = try? JSONSerialization.jsonObject(with: jsonData, options: []) as? [String: Any],
               let asJson = themeFromTmThemeJson(json: json) {
                return asJson
            }

            // read it as an XML into a JSON string
            guard let json = try PropertyListSerialization.propertyList(from: data,
                                                                        options: .mutableContainers,
                                                                        format: nil) as? [String: Any]
            else {
                Log.info("Failed to read plist for \(url)")
                return nil
            }

            return themeFromTmThemeJson(json: json)
        } catch {
            Log.info("Error loading theme: \(String(describing: error))")
        }

        return nil
    }

    /// Theme from TextMate Theme JSON
    /// - Parameter json: JSON Dict
    /// - Returns: AuroraTheme
    public func themeFromTmThemeJson(json: [String: Any]) -> AuroraTheme? {
        // textmate themes need to contain a `name`, but do not contain a `type`.
        // we will use the current dark/light mode setting to determine the type for the theme.
        // note that this means that if the user changes from light to dark mode or vice versa, themes
        // will not update to match it.
        // TODO: Allow tmthemes to change when user switches to light/dark mode
        let name = json["name"] as? String
        let type = UserDefaults.standard.string(forKey: "AppleInterfaceStyle") == "Dark" ? "dark" : "light"

        // unlike vscode themes, the `settings` field is mandatory.
        guard let settings = (json["settings"]) as? [[String: Any]] else { return nil }

        // get the HighlightTheme
        let highlightTheme = highlightThemeFromJson(json: settings)

        let defaultAttr = type == "light" ? AuroraTheme.EditorColors.defaultLight :
        AuroraTheme.EditorColors.defaultDark

        // if the theme does not contain a source, add one
        if !highlightTheme.settings.contains(where: { $0.isSource }) {
            let color = ThemeSetting(scope: "source",
                                     attributes: [ColorThemeAttribute(color: defaultAttr.text.nsColor)])
            highlightTheme.settings.append(color)
        }

        // create an editor
        let editor = AuroraTheme.EditorColors(text: defaultAttr.text,
                                              insertionPoint: defaultAttr.insertionPoint,
                                              invisibles: defaultAttr.invisibles,
                                              background: defaultAttr.background,
                                              lineHighlight: defaultAttr.lineHighlight,
                                              selection: defaultAttr.selection,
                                              highlightTheme: highlightTheme)

        // add the default monospace font to the theme
        // TODO: Allow custom fonts, font sizes, and font weights
        if let sourceIndex = highlightTheme.settings.firstIndex(where: { $0.isSource }) {
            var sourceSetting = highlightTheme.settings.remove(at: sourceIndex)
            sourceSetting.attributes.append(FontThemeAttribute(font: .monospacedSystemFont(ofSize: 13,
                                                                                           weight: .regular)))
            highlightTheme.settings.append(sourceSetting)
        }
        highlightTheme.root = HighlightTheme.createTrie(settings: highlightTheme.settings)

        return AuroraTheme(editor: editor,
                           terminal: type == "light" ? .defaultLight : .defaultDark,
                           author: "Imported via VSCode Theme",
                           license: "Imported via VSCode Theme",
                           metadataDescription: "none",
                           distributionURL: "https://www.youtube.com/watch?v=dQw4w9WgXcQ",
                           name: name ?? "Untitled Theme",
                           displayName: name ?? "Untitled Theme",
                           appearance: .universal,
                           version: "unknown")
    }
}
