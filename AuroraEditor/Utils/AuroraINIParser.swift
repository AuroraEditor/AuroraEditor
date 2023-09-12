//
//  AuroraINIParser.swift
//  Aurora Editor
//
//  Created by Wesley de Groot on 12/09/2023.
//  Copyright © 2023 Aurora Company. All rights reserved.
//

import Foundation

class AuroraINIParser {
    var iniFile = ""
    var currentSectionName = "main"

    typealias INIdictionary = [String: [String: String]]
    var iniDict = INIdictionary()

    init(ini: String) {
        iniFile = ini
    }

    func trim(_ string: String) -> String {
        let whitespaces = CharacterSet(charactersIn: " \n\r\t")
        return string.trimmingCharacters(in: whitespaces)
    }

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
