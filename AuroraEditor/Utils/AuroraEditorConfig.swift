//
//  AuroraEditorConfig.swift
//  Aurora Editor
//
//  Created by Wesley de Groot on 10/02/2024.
//  Copyright © 2024 Aurora Company. All rights reserved.
//

import Foundation

class AuroraEditorConfig {
    var parsed: [String: [String: Any]]? = [:]

    init(fromPath: String) {
        // try to load from this directory, otherwise go to the parent
        if let configFile = findEditorConfig(fromPath: fromPath),
           let configData = FileManager.default.contents(atPath: configFile),
           let configINI = String(data: configData, encoding: .utf8) {
            let parsed = AuroraINIParser(ini: configINI).parse()
            Log.info("INI=\(configFile)")
            Log.info(parsed)
            self.parsed = parsed
        }
    }

    public func get(value: String, for: String) {

    }

    private func findEditorConfig(fromPath: String) -> String? {
        let components = fromPath.components(separatedBy: "/")
        for number in stride(from: 0, to: components.count, by: 1) {
            var components = fromPath.components(separatedBy: "/")
            for _ in stride(from: 0, to: number, by: 1) {
                components.removeLast()
            }

            var temporaryPath = components.joined(separator: "/")
            temporaryPath += "/.editorconfig"

            if FileManager.default.fileExists(atPath: temporaryPath) {
                return temporaryPath
            }
        }

        return nil
    }
}
