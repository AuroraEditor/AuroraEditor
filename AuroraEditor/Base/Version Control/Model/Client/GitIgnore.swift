//
//  GitIgnore.swift
//  AuroraEditor
//
//  Created by Nanashi Li on 2022/08/13.
//  Copyright © 2022 Aurora Company. All rights reserved.
//  This source code is restricted for Aurora Editor usage only.
//

import Foundation

public struct GitIgnore {

    /// Read the contents of the repository .gitignore.
    ///
    /// Returns a promise which will either be rejected or resolved
    /// with the contents of the file. If there's no .gitignore file
    /// in the repository root the promise will resolve with null.
    func readGitIgnoreAtRoot(directoryURL: URL) throws -> String? {
        let ignorePath = try String(contentsOf: directoryURL) + ".gitignore"
        let content = try String(contentsOf: URL(string: ignorePath)!)
        return content
    }

    /// Persist the given content to the repository root .gitignore.
    ///
    /// If the repository root doesn't contain a .gitignore file one
    /// will be created, otherwise the current file will be overwritten.
    func saveGitIgnore(directoryURL: URL,
                       text: String) throws {
        let ignorePath = try String(contentsOf: directoryURL) + ".gitignore"

        if text.isEmpty {
            return
        }

        let fileContents = try formatGitIgnoreContents(text: text,
                                                       directoryURL: directoryURL)
        try text.write(to: URL(string: ignorePath)!, atomically: false, encoding: .utf8)
    }

    /// Add the given pattern or patterns to the root gitignore file
    func appendIgnoreRule(directoryURL: URL, patterns: [String]) throws {
        let text = try readGitIgnoreAtRoot(directoryURL: directoryURL)

        let currentContents = try formatGitIgnoreContents(text: text!,
                                                          directoryURL: directoryURL)

        let newPatternText = patterns.joined(separator: "\n")
        let newText = try formatGitIgnoreContents(text: "\(currentContents)\(newPatternText)",
                                                  directoryURL: directoryURL)

        try saveGitIgnore(directoryURL: directoryURL, text: newText)
    }

    /// Convenience method to add the given file path(s) to the repository's gitignore.
    ///
    /// The file path will be escaped before adding.
    func appendIgnoreFile(directoryURL: URL,
                          filePath: [String]) throws {
        let escapedFilePaths = filePath.map {
            escapeGitSpecialCharacters(pattern: $0)
        }

        return try appendIgnoreRule(directoryURL: directoryURL, patterns: escapedFilePaths)
    }

    // WARNING: I have a feeling this may not work, @#CK Apple
    /// Escapes a string from special characters used in a gitignore file
    func escapeGitSpecialCharacters(pattern: String) -> String {
        let specialCharacters = "/[\\[\\]!\\*\\#\\?]/g"

        return pattern.replacingOccurrences(of: specialCharacters, with: "\\")
    }

    /// Format the gitignore text based on the current config settings.
    ///
    /// This setting looks at core.autocrlf to decide which line endings to use
    /// when updating the .gitignore file.
    ///
    /// @param text - The text to format.
    /// @param directoryURL - The project url
    @discardableResult
    func formatGitIgnoreContents(text: String,
                                 directoryURL: URL) throws -> String {

        return ""
    }
}
