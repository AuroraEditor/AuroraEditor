//
//  ThemeJsonLoader.swift
//  Aurora Editor
//
//  Created by TAY KAI QUAN on 12/10/22.
//

import SwiftUI

// Useful reference for vscode themes: https://code.visualstudio.com/api/references/theme-color

class ThemeJsonLoader {

    static let shared: ThemeJsonLoader = .init()

    private init() {} // prevent ThemeJsonLoader from being created anywhere else

    typealias Attributes = AuroraTheme.Attributes

    /// Function that, taking in a filename for a bundled tmlanguage JSON file, returns a ``AuroraTheme`` from
    /// its contents
    /// - Parameter fileName: The name of the JSON file, not including the `.json` at the end
    /// - Returns: A ``AuroraTheme`` representing the contents of the JSON, or nil if the given json is invalid.
    @available(*, deprecated, message: "Please use loadJson:from:")
    public func loadBundledJson(fileName: String) -> AuroraTheme? { // TODO: Depreciate this and use loadJson:from:
        if let path = Bundle.main.path(forResource: fileName, ofType: "json") {
            let url = URL(fileURLWithPath: path)
            do {
                let data = try Data(contentsOf: url)
                return themeFromVscJson(jsonStr: String(decoding: data, as: UTF8.self))
            } catch {
                Log.info(String(describing: error))
            }
        } else {
            Log.info("Json not found")
        }
        return nil
    }

    /// Function that turns a JSON array into a ``HighlightTheme``.
    ///
    /// All textmate-based theme systems utilise the same format of themes, namely an array of
    /// dictionaries, where each dictionary contains a name, scope, and settings, and the global settings
    /// simply do not contain a scope. Therefore, this function can be used in all textmate-theme-like decoding.
    ///
    /// Example:
    /// ```json
    /// [
    ///    { // global settings
    ///       "settings": [ /*settings here*/ ]
    ///    },
    ///    { // single scope settings
    ///       "name": "name of setting",
    ///       "scope": "name of scope",
    ///       "settings": [ /*settings here*/ ]
    ///    },
    ///    { // multi scope settings
    ///       "name": "name of setting",
    ///       "scope": [ name of scopes here ]
    ///       "settings": [ /*settings here*/ ]
    ///    }
    /// ]
    /// ```
    ///
    /// - Parameter json: a JSON string
    /// - Returns: A ``HighlightTheme`` if decoding was successful, `nil` otherwise.
    func highlightThemeFromJson(json: [[String: Any]]) -> HighlightTheme {
        var themeSettings: [ThemeSetting] = []
        for colorSet in json {
            let scope = colorSet["scope"] as? String
            let scopes = colorSet["scope"] as? [String]
            guard let settings = colorSet["settings"] as? [String: String] else { continue }

            if let scope = scope {
                themeSettings.append(ThemeSetting(scope: scope, attributes: attributesFromJson(json: settings)))
            } else if let scopes = scopes {
                themeSettings.append(ThemeSetting(scopes: scopes, attributes: attributesFromJson(json: settings)))
            } else {
                themeSettings.append(ThemeSetting(scope: "source", attributes: attributesFromJson(json: settings)))
            }
        }
        return HighlightTheme(settings: themeSettings)
    }

    func attributesFromJson(json: [String: String]) -> [ThemeAttribute] {
        var attributes: [ThemeAttribute] = []
        for (item, detail) in json {
            if item == "foreground" {
                attributes.append(ColorThemeAttribute(color: NSColor(hex: detail)))
            } else if item == "fontStyle" {
                // TODO: Get font style working
            }
        }
        return attributes
    }
}
