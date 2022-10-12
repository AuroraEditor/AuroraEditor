//
//  ThemeJsonLoader.swift
//  AuroraEditor
//
//  Created by TAY KAI QUAN on 12/10/22.
//  Copyright © 2022 Aurora Company. All rights reserved.
//

import SwiftUI

class ThemeJsonLoader {

    static let shared: ThemeJsonLoader = .init()

    private init() {} // prevent ThemeJsonLoader from being created anywhere else

    /// Function that, taking in a filename for a bundled tmlanguage JSON file, returns a ``AuroraTheme`` from its contents
    /// - Parameter fileName: The name of the JSON file, not including the `.json` at the end
    /// - Returns: A ``AuroraTheme`` representing the contents of the JSON, or nil if the given json is invalid.
    public func loadBundledJson(fileName: String) -> AuroraTheme? { // TODO: Depreciate this and use loadJson:from:
        if let path = Bundle.main.path(forResource: fileName, ofType: "json") {
            let url = URL(fileURLWithPath: path)
            do {
                let data = try Data(contentsOf: url)
                return themeFromJson(jsonStr: String(decoding: data, as: UTF8.self))
            } catch {
                Log.info(String(describing: error))
            }
        } else {
            Log.info("Json not found")
        }
        return nil
    }

    /// Function that, taking in a URL for a vscode or textmate theme JSON file,
    /// returns an ``AuroraTheme`` from its contents
    /// - Parameter url: The URL of the JSON file
    /// - Returns: An ``AuroraTheme`` representing the contents of the JSON, or
    /// nil if the given URL cannot be read as a grammar json.
    public func loadJson(from url: URL) -> AuroraTheme? {
        do {
            let data = try Data(contentsOf: url)
            return themeFromJson(jsonStr: String(decoding: data, as: UTF8.self))
        } catch {
            Log.info(String(describing: error))
        }
        return nil
    }

    public func themeFromJson(jsonStr: String) -> AuroraTheme? {
        guard let jsonData = jsonStr.data(using: .utf8),
              let json = try? JSONSerialization.jsonObject(with: jsonData, options: []) as? [String: Any]
        else {
            Log.info("Failed to load json")
            return nil
        }

        // TODO: Load the theme
        return nil
    }
}
