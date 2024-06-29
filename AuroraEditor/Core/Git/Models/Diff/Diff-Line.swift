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
    /// Context line
    case context

    /// Line was added
    case add

    /// Line was deleted
    case delete

    /// Line was modified
    case hunk
}

/// Track details related to each line in the diff
class DiffLine {
    /// Text
    var text: String

    /// Type
    var type: DiffLineType
    // Line number in the original diff patch (before expanding it), or nil if
    // it was added as part of a diff expansion action./

    /// Original line number
    var originalLineNumber: Int?

    /// Old line number
    var oldLineNumber: Int?

    /// New line number
    var newLineNumber: Int?

    /// No trailing newline
    var noTrailingNewLine: Bool = false

    /// Initialize a new diff line
    /// 
    /// - Parameter text: The text of the line
    /// - Parameter type: The type of line
    /// - Parameter originalLineNumber: The original line number
    /// - Parameter oldLineNumber: The old line number
    /// - Parameter newLineNumber: The new line number
    /// - Parameter noTrailingNewLine: Whether the line has a trailing newline
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
    /// 
    /// - Parameter noTrailingNewLine: Trailing newline?
    /// 
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
    /// 
    /// - Returns: is includable?
    public func isIncludeableLine() -> Bool {
        return self.type == DiffLineType.add || self.type == DiffLineType.delete
    }

    /// The content of the line, i.e., without the line type marker.
    /// 
    /// - Returns: The content of the line
    public func content() -> String {
        return self.text.substring(1)
    }
}
