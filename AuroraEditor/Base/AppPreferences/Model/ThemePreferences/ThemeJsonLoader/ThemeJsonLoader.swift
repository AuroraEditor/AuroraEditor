//
//  ThemeJsonLoader.swift
//  AuroraEditor
//
//  Created by TAY KAI QUAN on 12/10/22.
//  Copyright © 2022 Aurora Company. All rights reserved.
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
}
