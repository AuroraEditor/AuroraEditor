//
//  Raw-Diff.swift
//  Aurora Editor
//
//  Created by Nanashi Li on 2022/08/29.
//  Copyright © 2023 Aurora Company. All rights reserved.
//

import Foundation

/// The type of expansion that can be performed on a hunk header.
enum DiffHunkExpansionType: String {
    /// The hunk header cannot be expanded at all.
    case none = "None"

    /// The hunk header can be expanded up exclusively. Only the first hunk can be
    /// expanded up exclusively.
    case up = "Up"

    /// The hunk header can be expanded down exclusively. Only the last hunk (if
    /// it's the dummy hunk with only one line) can be expanded down exclusively.
    case down = "Down"

    /// The hunk header can be expanded both up and down.
    case both = "Both"

    /// The hunk header represents a short gap that, when expanded, will
    /// result in merging this hunk and the hunk above.
    case short = "Short"
}

/// Each diff is made up of a number of hunks
class DiffHunk {
    /// The hunk header
    var header: DiffHunkHeader

    /// The lines in the hunk
    var lines: [DiffLine]

    /// The line number in the unified diff where this hunk starts
    var unifiedDiffStart: Int

    /// The line number in the unified diff where this hunk ends
    var unifiedDiffEnd: Int

    /// The type of expansion that can be performed on this hunk
    var expansionType: DiffHunkExpansionType

    /// Initialize a new diff hunk
    /// 
    /// - Parameter header: The hunk header
    /// - Parameter lines: The lines in the hunk
    /// - Parameter unifiedDiffStart: The line number in the unified diff where this hunk starts
    /// - Parameter unifiedDiffEnd: The line number in the unified diff where this hunk ends
    /// - Parameter expansionType: The type of expansion that can be performed on this hunk
    init(header: DiffHunkHeader,
         lines: [DiffLine],
         unifiedDiffStart: Int,
         unifiedDiffEnd: Int,
         expansionType: DiffHunkExpansionType) {
        self.header = header
        self.lines = lines
        self.unifiedDiffStart = unifiedDiffStart
        self.unifiedDiffEnd = unifiedDiffEnd
        self.expansionType = expansionType
    }
}

/// The header of a hunk in a diff
class DiffHunkHeader {
    /// The old start line
    var oldStartLine: Int

    /// The number of lines in the old file
    var oldLineCount: Int

    /// The new start line
    var newStartLine: Int

    /// The number of lines in the new file
    var newLineCount: Int

    /// Initialize a new hunk header
    /// 
    /// - Parameter oldStartLine: The old start line
    /// - Parameter oldLineCount: The number of lines in the old file
    /// - Parameter newStartLine: The new start line
    /// - Parameter newLineCount: The number of lines in the new file
    init(oldStartLine: Int, oldLineCount: Int, newStartLine: Int, newLineCount: Int) {
        self.oldStartLine = oldStartLine
        self.oldLineCount = oldLineCount
        self.newStartLine = newStartLine
        self.newLineCount = newLineCount
    }

    /// to diff line representation
    /// 
    /// - Returns: diff line representation
    public func toDiffLineRepresentation() -> String {
        return "@@ -\(self.oldStartLine),\(self.oldLineCount) +\(self.newStartLine),\(self.newLineCount) @@"
    }
}

/// Interface: Raw diff
class IRawDiff {
    /// The plain text contents of the diff header. This contains
    /// everything from the start of the diff up until the first
    /// hunk header starts. Note that this does not include a trailing
    /// newline.
    var header: String

    /// The plain text contents of the diff. This contains everything
    /// after the diff header until the last character in the diff.
    ///
    /// Note that this does not include a trailing newline nor does
    /// it include diff 'no newline at end of file' comments. For
    /// no-newline information, consult the DiffLine noTrailingNewLine
    /// property.
    var contents: String

    /// Each hunk in the diff with information about start, and end
    /// positions, lines and line statuses.
    var hunks: [DiffHunk]

    /// Whether or not the unified diff indicates that the contents
    /// could not be diffed due to one of the versions being binary.
    var isBinary: Bool

    /// The largest line number in the diff
    var maxLineNumber: Int

    /// Whether or not the diff has invisible bidi characters
    var hasHiddenBidiChars: Bool

    /// Initialize a new raw diff
    /// 
    /// - Parameter header: The plain text contents of the diff header
    /// - Parameter contents: The plain text contents of the diff
    /// - Parameter hunks: Each hunk in the diff
    /// - Parameter isBinary: Whether or not the unified diff indicates that the contents \
    ///                       could not be diffed due to one of the versions being binary
    /// - Parameter maxLineNumber: The largest line number in the diff
    /// - Parameter hasHiddenBidiChars: Whether or not the diff has invisible bidi characters
    init(header: String,
         contents: String,
         hunks: [DiffHunk],
         isBinary: Bool,
         maxLineNumber: Int,
         hasHiddenBidiChars: Bool) {
        self.header = header
        self.contents = contents
        self.hunks = hunks
        self.isBinary = isBinary
        self.maxLineNumber = maxLineNumber
        self.hasHiddenBidiChars = hasHiddenBidiChars
    }
}
