//
//  AuroraEditorConfig.swift
//  Aurora Editor
//
//  Created by Wesley de Groot on 10/02/2024.
//  Copyright © 2024 Aurora Company. All rights reserved.
//

import Foundation

class AuroraEditorConfig {
    enum EditorConfigKeys: String {
        case indent_style
        // swiftlint:disable:previous identifier_name
        case indent_size
        // swiftlint:disable:previous identifier_name
        case tab_width
        // swiftlint:disable:previous identifier_name
        case end_of_line
        // swiftlint:disable:previous identifier_name
        case charset
        case trim_trailing_whitespace
        // swiftlint:disable:previous identifier_name
        case insert_final_newline
        // swiftlint:disable:previous identifier_name
        case max_line_length
        // swiftlint:disable:previous identifier_name
    }

    var parsed: [String: [String: Any]]? = [:]

    var defaults: [String: [String: Any]] = [
        "*": [
            "indent_style": "space",
            "indent_size": "4",
            "tab_width": "4",
            "end_of_line": "lf",
            "charset": "utf8",
            "trim_trailing_whitespace": "true",
            "insert_final_newline": "true",
            "max_line_length": "10000"
        ]
    ]

    init(fromPath: String) {
        if let configFile = findEditorConfig(fromPath: fromPath),
           let configData = FileManager.default.contents(atPath: configFile),
           let configINI = String(data: configData, encoding: .utf8) {
            let parsed = AuroraINIParser(ini: configINI).parse()
            Log.info("INI=\(configFile)")
            Log.info(parsed)
            self.parsed = parsed
        }
    }

    /// Get value for type
    /// - Parameters:
    ///   - value: value type
    ///   - for: for type
    public func get(value: EditorConfigKeys, for file: String = "*") -> Any? {
        return parsed?[getKeyNameFor(file: file)]?[value.rawValue]
            ?? parsed?["*"]?[value.rawValue]
            ?? defaults[getKeyNameFor(file: file)]?[value.rawValue]
            ?? defaults["*"]?[value.rawValue]
            ?? nil
    }

    private func getKeyNameFor(file: String) -> String {
        return "*"
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
