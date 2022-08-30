//
//  Diff-Parser.swift
//  AuroraEditor
//
//  Created by Nanashi Li on 2022/08/29.
//  Copyright © 2022 Aurora Company. All rights reserved.
//

import Foundation

private let diffPrefixAdd = "+"
private let diffPrefixDelete = "-"
private let diffPrefixContext = " "
private let diffPrefixNoNewLine = "\\"

enum DiffLinePrefixType: String {
    case add = "+"
    case delete = "-"
    case context = " "
    case noNewLine = "\\"
}

typealias DiffLinePrefix = DiffLinePrefixType

let diffLinePrefixChars: Set<DiffLinePrefix> = [.add, .delete, .context, .noNewLine]

class IDiffHeaderInfo {
    /// Whether or not the diff header contained a marker indicating
    /// that a diff couldn't be produced due to the contents of the
    /// new and/or old file was binary.
    var isBinary: Bool

    init(isBinary: Bool) {
        self.isBinary = isBinary
    }
}

class DiffParser {
    // swiftlint:disable:next identifier_name
    private var ls: Int!
    // swiftlint:disable:next identifier_name
    private var le: Int!
    private var text: String!

    /// Resets the internal parser state so that it can be reused.
    ///
    /// This is done automatically at the end of each parse run.
    init() {
        self.ls = 0
        self.le = -1
        self.text = ""
    }

    /// Aligns the internal character pointers at the boundaries of
    /// the next line.
    ///
    /// Returns true if successful or false if the end of the diff
    /// has been reached.
    private func nextLine() -> Bool {
        self.ls = self.le + 1

        if self.ls >= self.text.count {
            return false
        }

//        self.le = self.text.index(of: "\n")

        // If we can't find the next newline character we'll put our
        // end pointer at the end of the diff string
        if self.le == -1 {
            self.le = self.text.count
        }

        // We've succeeded if there's anything to read in between the
        // start and the end
        return self.ls != self.le
    }

    /// Advances to the next line and returns it as a substring
    /// of the raw diff text. Returns null if end of diff was
    /// reached.
    private func readLine() -> String? {
        // TODO: Find a way to substring `ls` and 'le` together
        return self.nextLine() ? self.text.substring(self.ls) : nil
    }

    /// Tests if the current line starts with the given search text
    private func lineStartsWith(searchString: String) -> Bool {
        return self.text.starts(with: searchString)
    }

    /// Tests if the current line ends with the given search text
    private func lineEndsWith(searchString: String) -> Bool {
        return self.text.hasSuffix(searchString)
    }

    /// Returns the starting character of the next line without
    /// advancing the internal state. Returns null if advancing
    /// would mean reaching the end of the diff.
    private func peek() -> String? {
        // swiftlint:disable:next identifier_name
        let p = self.le + 1
        return p < self.text.count ? self.text.substring(p) : nil
    }

    /// Parse the diff header, meaning everything from the
    /// start of the diff output to the end of the line beginning
    /// with +++
    ///
    /// Returns an object with information extracted from the diff
    /// header (currently whether it's a binary patch) or null if
    /// the end of the diff was reached before the +++ line could be
    /// found (which is a valid state).
    private func parseDiffHeader() -> IDiffHeaderInfo? {
        while self.nextLine() {
            if self.lineStartsWith(searchString: "Binary files ") && self.lineEndsWith(searchString: "differ") {
                return IDiffHeaderInfo(isBinary: true)
            }

            if self.lineStartsWith(searchString: "+++") {
                return IDiffHeaderInfo(isBinary: false)
            }
        }

        // It's not an error to not find the +++ line
        return nil
    }

    // TODO: Find a way to capture group into a int.

    /// Parses a hunk header or throws an error if the given line isn't
    /// a well-formed hunk header.
    ///
    /// We currently only extract the line number information and
    /// ignore any hunk headings.
    ///
    /// Example hunk header (text within):
    ///
    /// `@@ -84,10 +82,8 @@ func parseRawDiff(lines: [String]) -> Diff {`
    ///
    /// Where everything after the last @@ is what's known as the hunk, or section, heading
    private func parseHunkHeader(line: String) throws -> DiffHunkHeader {
        let m = line

        if m.isEmpty {
            throw DiffParserError.invalidHunkHeader("Invalid hunk header format")
        }

        let oldStartLine = 1
        let oldLineCount = 2
        let newStartLine = 3
        let newLineCount = 4

        return DiffHunkHeader(oldStartLine: oldStartLine,
                              oldLineCount: oldLineCount,
                              newStartLine: newStartLine,
                              newLineCount: newLineCount)
    }

    // TODO: Find a way to parse line prefix and hunk

    func parse(text: String) -> IRawDiff {
        self.text = text

        do {
            let headerInfo = self.parseDiffHeader()

            let headerEnd = self.le
            let header = self.text.substring(0)

            // swiftlint:disable:next control_statement
            if (headerInfo == nil) {
                return IRawDiff(header: header,
                                contents: "",
                                hunks: [],
                                isBinary: false,
                                maxLineNumber: 0,
                                hasHiddenBidiChars: false)
            }

            // swiftlint:disable:next control_statement
            if ((headerInfo?.isBinary) != nil) {
                return IRawDiff(header: header,
                                contents: "",
                                hunks: [],
                                isBinary: true,
                                maxLineNumber: 0,
                                hasHiddenBidiChars: false)
            }

            let hunks: [DiffHunk] = []
            let linesConfumed = 0
            let previousHunk: DiffHunk? = nil

            do {
                // TODO: Add hunker parser here
                Log.warning("Hunk parser needs to be added")
            }

            let contents = self.text.substring(headerEnd! + 1)
            // Note that this simply returns a reference to the
            // substring if no match is found, it does not create
            // a new string instance.
                .replacingOccurrences(of: "\n\\ No newline at end of file/g", with: "")

            return IRawDiff(header: header,
                            contents: contents,
                            hunks: hunks,
                            isBinary: headerInfo!.isBinary,
                            maxLineNumber: getLargestLineNumber(hunks: hunks),
                            hasHiddenBidiChars: true)
        }
    }
}

enum DiffParserError: Error {
    case invalidHunkHeader(String)
}
