//
//  Diff-Line.swift
//  Aurora Editor
//
//  Created by Nanashi Li on 2022/08/29.
//  Copyright © 2023 Aurora Company. All rights reserved.
//

import Foundation

/// Indicate what a line in the diff represents
enum DiffLineType {
    case context
    case add
    case delete
    case hunk
}

/// Track details related to each line in the diff
class DiffLine {
    var text: String
    var type: DiffLineType
    // Line number in the original diff patch (before expanding it), or nil if
    // it was added as part of a diff expansion action./
    var originalLineNumber: Int?
    var oldLineNumber: Int?
    var newLineNumber: Int?
    var noTrailingNewLine: Bool = false

    init(text: String,
         type: DiffLineType,
         originalLineNumber: Int? = nil,
         oldLineNumber: Int? = nil,
         newLineNumber: Int? = nil,
         noTrailingNewLine: Bool) {
        self.text = text
        self.type = type
        self.originalLineNumber = originalLineNumber
        self.oldLineNumber = oldLineNumber
        self.newLineNumber = newLineNumber
        self.noTrailingNewLine = noTrailingNewLine
    }

    /// With no trailing newline
    /// - Parameter noTrailingNewLine: Trailing newline?
    /// - Returns: Diff line
    public func withNoTrailingNewLine(noTrailingNewLine: Bool) -> DiffLine {
        return DiffLine(text: self.text,
                        type: self.type,
                        originalLineNumber: self.originalLineNumber,
                        oldLineNumber: self.oldLineNumber,
                        newLineNumber: self.newLineNumber,
                        noTrailingNewLine: noTrailingNewLine)
    }

    /// Is includable line
    /// - Returns: is includable?
    public func isIncludeableLine() -> Bool {
        return self.type == DiffLineType.add || self.type == DiffLineType.delete
    }

    /// The content of the line, i.e., without the line type marker.
    public func content() -> String {
        return self.text.substring(1)
    }
}
