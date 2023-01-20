//
//  ThemeJsonLoader+AuroraTheme(Old).swift
//  Aurora Editor
//
//  Created by TAY KAI QUAN on 17/10/22.
//  Copyright © 2023 Aurora Company. All rights reserved.
//

import SwiftUI
import AppKit

extension ThemeJsonLoader {
    /// Function that, taking in a URL for an old AuroraTheme JSON file,
    /// returns an ``AuroraTheme`` from its contents
    /// - Parameter url: The URL of the JSON file
    /// - Returns: An ``AuroraTheme`` representing the contents of the JSON, or
    /// nil if the given URL cannot be read as a grammar json.
    public func loadOldAEThemeJson(from url: URL) -> AuroraTheme? {
        do {
            let data = try Data(contentsOf: url)
            return themeFromOldAEThemeJson(jsonStr: String(decoding: data, as: UTF8.self))
        } catch {
            Log.info("Error loading theme: \(String(describing: error))")
        }

        return nil
    }

    /// Theme from "old" AE Theme JSON file
    /// - Parameter jsonStr: JSON String
    /// - Returns: AuroraTheme
    public func themeFromOldAEThemeJson(jsonStr: String) -> AuroraTheme? {
        guard let jsonData = jsonStr.data(using: .utf8),
              let json = try? JSONSerialization.jsonObject(with: jsonData, options: []) as? [String: Any]
        else {
            Log.info("Failed to load vsc json")
            return nil
        }

        // All old AEThemes are exactly the same, containing the following fields:
        // author, distributionURL, version, license, type, name, displayName, description,
        // editor, terminal
        guard let author = json["author"] as? String,
              let distributionURL = json["distributionURL"] as? String,
              let version = json["version"] as? String,
              let license = json["license"] as? String,
              let type = json["type"] as? String,
              let name = json["name"] as? String,
              let displayName = json["displayName"] as? String,
              let description = json["description"] as? String,
              let editorRaw = json["editor"] as? [String: [String: String]],
              let terminalRaw = json["terminal"] as? [String: [String: String]],
              let editor = editorFromOldAEThemeJson(json: editorRaw),
              let terminal = terminalFromOldAEThemeJson(json: terminalRaw)
        else { return nil }

        return AuroraTheme(editor: editor,
                           terminal: terminal,
                           author: author,
                           license: license,
                           metadataDescription: description,
                           distributionURL: distributionURL,
                           name: name,
                           displayName: displayName,
                           appearance: type == "dark" ? .dark : .light,
                           version: version)
    }

    // swiftlint:disable:next function_body_length
    func editorFromOldAEThemeJson(json: [String: [String: String]]) -> AuroraTheme.EditorColors? {
        guard
              // To be translated to HighlightTheme
              let strings = json["strings"]?["color"],
              let comments = json["comments"]?["color"],
              let numbers = json["numbers"]?["color"],
              let commands = json["commands"]?["color"],
              let values = json["values"]?["color"],
              let keywords = json["keywords"]?["color"],
              let types = json["types"]?["color"],
              let variables = json["variables"]?["color"],
              let attributes = json["attributes"]?["color"],
              let characters = json["characters"]?["color"],

              // To be fed directly into EditorColors
              let text = json["text"]?["color"],
              let insertionPoint = json["insertionPoint"]?["color"],
              let invisibles = json["invisibles"]?["color"],
              let background = json["background"]?["color"],
              let lineHighlight = json["lineHighlight"]?["color"],
              let selection = json["selection"]?["color"]
        else { return nil }

        // NOTE: Not sure if all these are correct. May need double checking.
        // TODO: Double check these values
        let highlightTheme = HighlightTheme(settings: [
            ThemeSetting(
                scope: "source",
                attributes: [
                            FontThemeAttribute(font: .monospacedSystemFont(ofSize: 13,
                                                                           weight: .regular)),
                            ColorThemeAttribute(color: NSColor(hex: text))
            ]),
            ThemeSetting(scope: "string",
                         attributes: [ColorThemeAttribute(color: NSColor(hex: strings))]),
            ThemeSetting(scope: "comment",
                         attributes: [ColorThemeAttribute(color: NSColor(hex: comments))]),
            ThemeSetting(scope: "constant.numeric",
                         attributes: [ColorThemeAttribute(color: NSColor(hex: numbers))]),
            ThemeSetting(scope: "entity.name.function",
                         attributes: [ColorThemeAttribute(color: NSColor(hex: commands))]),
            ThemeSetting(scope: "variable",
                         attributes: [ColorThemeAttribute(color: NSColor(hex: values))]),
            ThemeSetting(scope: "keyword",
                         attributes: [ColorThemeAttribute(color: NSColor(hex: keywords))]),
            ThemeSetting(scope: "entity.name.type",
                         attributes: [ColorThemeAttribute(color: NSColor(hex: types))]),
            ThemeSetting(scope: "variable",
                         attributes: [ColorThemeAttribute(color: NSColor(hex: variables))]),
            ThemeSetting(scope: "entity.other.attribute-name",
                         attributes: [ColorThemeAttribute(color: NSColor(hex: attributes))]),
            ThemeSetting(scope: "constant.character.entity",
                         attributes: [ColorThemeAttribute(color: NSColor(hex: characters))])
        ])

        return AuroraTheme.EditorColors(text: AuroraTheme.Attributes(color: text),
                                        insertionPoint: AuroraTheme.Attributes(color: insertionPoint),
                                        invisibles: AuroraTheme.Attributes(color: invisibles),
                                        background: AuroraTheme.Attributes(color: background),
                                        lineHighlight: AuroraTheme.Attributes(color: lineHighlight),
                                        selection: AuroraTheme.Attributes(color: selection),
                                        highlightTheme: highlightTheme)
    }

    func terminalFromOldAEThemeJson(json: [String: [String: String]]) -> AuroraTheme.TerminalColors? {
        guard let textRaw = json["text"]?["color"],
              let boldTextRaw = json["boldText"]?["color"],
              let cursorRaw = json["cursor"]?["color"],
              let backgroundRaw = json["background"]?["color"],
              let selectionRaw = json["selection"]?["color"],
              let blackRaw = json["black"]?["color"],
              let redRaw = json["red"]?["color"],
              let greenRaw = json["green"]?["color"],
              let yellowRaw = json["yellow"]?["color"],
              let blueRaw = json["blue"]?["color"],
              let magentaRaw = json["magenta"]?["color"],
              let cyanRaw = json["cyan"]?["color"],
              let whiteRaw = json["white"]?["color"],
              let brightBlackRaw = json["brightBlack"]?["color"],
              let brightRedRaw = json["brightRed"]?["color"],
              let brightGreenRaw = json["brightGreen"]?["color"],
              let brightYellowRaw = json["brightYellow"]?["color"],
              let brightBlueRaw = json["brightBlue"]?["color"],
              let brightMagentaRaw = json["brightMagenta"]?["color"],
              let brightCyanRaw = json["brightCyan"]?["color"],
              let brightWhiteRaw = json["brightWhite"]?["color"]
        else { return nil }

        return AuroraTheme.TerminalColors(text: AuroraTheme.Attributes(color: textRaw),
                                          boldText: AuroraTheme.Attributes(color: boldTextRaw),
                                          cursor: AuroraTheme.Attributes(color: cursorRaw),
                                          background: AuroraTheme.Attributes(color: backgroundRaw),
                                          selection: AuroraTheme.Attributes(color: selectionRaw),
                                          black: AuroraTheme.Attributes(color: blackRaw),
                                          red: AuroraTheme.Attributes(color: redRaw),
                                          green: AuroraTheme.Attributes(color: greenRaw),
                                          yellow: AuroraTheme.Attributes(color: yellowRaw),
                                          blue: AuroraTheme.Attributes(color: blueRaw),
                                          magenta: AuroraTheme.Attributes(color: magentaRaw),
                                          cyan: AuroraTheme.Attributes(color: cyanRaw),
                                          white: AuroraTheme.Attributes(color: whiteRaw),
                                          brightBlack: AuroraTheme.Attributes(color: brightBlackRaw),
                                          brightRed: AuroraTheme.Attributes(color: brightRedRaw),
                                          brightGreen: AuroraTheme.Attributes(color: brightGreenRaw),
                                          brightYellow: AuroraTheme.Attributes(color: brightYellowRaw),
                                          brightBlue: AuroraTheme.Attributes(color: brightBlueRaw),
                                          brightMagenta: AuroraTheme.Attributes(color: brightMagentaRaw),
                                          brightCyan: AuroraTheme.Attributes(color: brightCyanRaw),
                                          brightWhite: AuroraTheme.Attributes(color: brightWhiteRaw))
    }
}
