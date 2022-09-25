//
//  CodeEditor+Position.swift
//  AuroraEditor
//
//  Created by Nanashi Li on 2022/09/24.
//  Copyright © 2022 Aurora Company. All rights reserved.
//

import Foundation

extension CodeEditor.Position: RawRepresentable, Codable {
    public init?(rawValue: String) {
        func parseNSRange(lexeme: String) -> NSRange? {
            let components = lexeme.components(separatedBy: ":")
            guard components.count == 2,
                  let location = Int(components[0]),
                  let length = Int(components[1])
            else { return nil }
            return NSRange(location: location, length: length)
        }

        let components = rawValue.components(separatedBy: "|")
        if components.count == 2 {
            selections = components[0].components(separatedBy: ";").compactMap { parseNSRange(lexeme: $0) }
            verticalScrollFraction = CGFloat(Double(components[1]) ?? 0)
        } else { self = CodeEditor.Position() }
    }

    public var rawValue: String {
        let selectionsString = selections.map { "\($0.location):\($0.length)" }.joined(separator: ";"),
            verticalScrollFractionString = String(describing: verticalScrollFraction)
        return selectionsString + "|" + verticalScrollFractionString
    }
}
