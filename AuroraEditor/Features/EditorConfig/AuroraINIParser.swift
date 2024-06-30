//
//  AuroraINIParser.swift
//  Aurora Editor
//
//  Created by Wesley de Groot on 12/09/2023.
//  Copyright © 2023 Aurora Company. All rights reserved.
//

import Foundation

/// INI Parser
class AuroraINIParser {
    /// INI File
    var iniFile = ""

    /// Current Section Name
    var currentSectionName = "main"

    /// INI Dictionary = [String: [String: String]]
    typealias INIdictionary = [String: [String: String]]

    /// INI Dictionary
    var iniDict = INIdictionary()

    /// Initialize the INI Parser
    /// 
    /// - Parameter ini: INI File
    init(ini: String) {
        iniFile = ini
    }

    /// Trim a string
    /// 
    /// - Parameter string: String
    /// 
    /// - Returns: Trimmed string
    func trim(_ string: String) -> String {
        let whitespaces = CharacterSet(charactersIn: " \n\r\t")
        return string.trimmingCharacters(in: whitespaces)
    }

    /// Parse the INI File
    /// 
    /// - Returns: INI Dictionary
    func parse() -> INIdictionary {
        for line in iniFile.components(separatedBy: "\n") {
            let line = trim(line)

            if line.hasPrefix("#") || line.hasPrefix(";") {
                continue
            } else if line.hasPrefix("[") && line.hasSuffix("]") {
                currentSectionName = line
                    .replacingOccurrences(of: "[", with: "")
                    .replacingOccurrences(of: "]", with: "")
            } else if let (key, val) = parseLine(line) {
                var section = iniDict[currentSectionName] ?? [:]
                section[key] = val
                iniDict[currentSectionName] = section
            }
        }

        return iniDict
    }

    /// Parse a line
    /// 
    /// - Parameter line: Line
    /// 
    /// - Returns: Tuple with key and value
    func parseLine(_ line: String) -> (String, String)? {
        let parts = line.split(separator: "=", maxSplits: 1)
        if parts.count == 2 {
            let key = trim(String(parts[0]))
            var val = trim(String(parts[1]))

            if val.hasPrefix("\"") && val.hasSuffix("\"") {
                val = String(val.dropFirst(1))
                val = String(val.dropLast(1))
            }

            return (key, val)
        }
        return nil
    }
}
