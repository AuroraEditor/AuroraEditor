//
//  Diff-Data.swift
//  Aurora Editor
//
//  Created by Nanashi Li on 2022/08/29.
//  Copyright © 2023 Aurora Company. All rights reserved.
//

import Foundation

/// The maximum size of a diff that can be rendered in Aurora Editor
let maximumDiffStringSize = 268435441

enum DiffType {
    /// Changes to a text file, which may be partially selected for commit
    case text

    /// Changes to a file with a known extension, which can be viewed in the editor
    case image

    /// Changes to an unknown file format, which Git is unable to present in a human-friendly format
    case binary

    /// Change to a repository which is included as a submodule of this repository
    case submodule

    /// Diff is large enough to degrade ux if rendered
    case largeText

    /// Diff that will not be rendered
    case unrenderable
}

/// The type of line ending in a file
enum LineEndingType: String {
    /// Carriage return (Mac)
    case cr = "CR"
    // swiftlint:disable:previous identifier_name

    /// Line feed return (Unix)
    case lf = "LF"
    // swiftlint:disable:previous identifier_name

    /// Carriage return and line feed (Windows)
    case crlf = "CRLF"
}

typealias LineEnding = LineEndingType

/// A change in line endings in a file
class LineEndingsChange {
    /// The original line ending
    var from: LineEnding

    /// The new line ending
    var to: LineEnding

    /// Initialize a new line endings change
    /// 
    /// - Parameter from: The original line ending
    /// - Parameter to: The new line ending
    init(from: LineEnding,
         to: LineEnding) {
        self.from = from
        self.to = to
    }
}

/// Parse the line ending string into an enum value (or `null` if unknown)
/// 
/// - Parameter text: The line ending string
/// 
/// - Returns: The line ending enum value
func parseLineEndingText(text: String) -> LineEnding? {
    let input = text.trimmingCharacters(in: .whitespacesAndNewlines)
    switch input {
    case "CR":
        return .cr
    case "LF":
        return .lf
    case "CRLF":
        return .crlf
    default:
        return nil
    }
}

/// Interface: Data returned as part of a textual diff from Aurora Editor
class ITextDiffData {
    /// The unified text diff - including headers and context
    var text: String

    /// The diff contents organized by hunk - how the git CLI outputs to the caller
    var hunks: [DiffHunk]

    /// A warning from Git that the line endings have changed in this file and will affect the commit
    var lineEndingsChange: LineEndingsChange?

    /// The largest line number in the diff
    var maxLineNumber: Int

    /// Whether or not the diff has invisible bidi characters
    var hasHiddenBidiChars: Bool

    /// Initialize a new text diff data
    /// 
    /// - Parameter text: The unified text diff
    /// - Parameter hunks: The diff contents organized by hunk
    /// - Parameter lineEndingsChange: A warning from Git that the line endings have changed in this file
    /// - Parameter maxLineNumber: The largest line number in the diff
    /// - Parameter hasHiddenBidiChars: Whether or not the diff has invisible bidi characters
    init(text: String,
         hunks: [DiffHunk],
         lineEndingsChange: LineEndingsChange? = nil,
         maxLineNumber: Int,
         hasHiddenBidiChars: Bool) {
        self.text = text
        self.hunks = hunks
        self.lineEndingsChange = lineEndingsChange
        self.maxLineNumber = maxLineNumber
        self.hasHiddenBidiChars = hasHiddenBidiChars
    }
}

/// Interface: Text diff
class ITextDiff: ITextDiffData {
    /// Text diff type
    var kind: DiffType = .text
}

/// Interface: Image diff
class IImageDiff {
    /// Image diff type
    var kind: DiffType = .image
}

/// Interface: Binary diff
class IBinaryDiff {
    /// Binary diff type
    var kind: DiffType = .binary
}

/// Interface: Large text diff
class ILargeTextDiff: ITextDiffData {
    /// Large text diff type
    var kind: DiffType = .largeText
}

/// Interface: Unrenderable diff
class IUnrenderableDiff {
    /// Unrenderable diff type
    var kind: DiffType = .unrenderable
}

/// Interface: Diff types
enum IDiffTypes {
    /// Text diff
    case text(ITextDiff)

    /// Image diff
    case image(IImageDiff)

    /// Binary diff
    case binary(IBinaryDiff)

    /// Large text diff
    case large(ILargeTextDiff)

    /// Unrenderable diff
    case unrenderable(IUnrenderableDiff)
}

/// The union of diff types that can be rendered in Aurora Editor
typealias IDiff = IDiffTypes
