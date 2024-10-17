//
//  WorkspaceDocument+Search.swift
//  Aurora Editor
//
//  Created by Pavel Kasila on 30.04.22.
//  Copyright © 2023 Aurora Company. All rights reserved.
//

import Foundation

extension WorkspaceDocument {
    /// The search state
    @MainActor
    final class SearchState: ObservableObject {
        /// The workspace document
        weak var workspace: WorkspaceDocument?

        /// The selected mode
        var selectedMode: [SearchModeModel] = [
            .Find,
            .Text,
            .Containing
        ]

        /// The search result
        @Published
        var searchResult: [SearchResultModel] = []

        /// The search result count
        @Published
        var searchResultCount: Int = 0

        /// A unique ID for the current search results. Used to "re-search" with the same
        /// search text but refresh results and UI.
        @Published
        var searchId: UUID?

        /// Whether to ignore case when searching
        var ignoreCase: Bool = true

        /// Creates a new instance of the search state.
        /// 
        /// - Parameter workspace: The workspace document.
        init(_ workspace: WorkspaceDocument) {
            self.workspace = workspace
        }

        /// Searches the entire workspace for the given string, using the ``selectedMode`` modifiers
        /// to modify the search if needed.
        ///
        /// This method will update ``searchResult`` and ``searchResultCount`` with any matched
        /// search results. See ``Search.SearchResultModel`` and ``Search.SearchResultMatchModel``
        /// for more information on search results and matches.
        ///
        /// - Parameter text: The search text to search for. Pass `nil` to this parameter to clear
        ///                   the search results.
        func search(_ text: String?) {
            guard let text = text else {
                searchResult = []
                searchResultCount = 0
                searchId = nil
                return
            }

            let textToCompare = ignoreCase ? text.lowercased() : text
            self.searchResult = []
            self.searchId = UUID()
            guard let url = self.workspace?.fileURL else { return }
            let enumerator = FileManager.default.enumerator(at: url,
                                                            includingPropertiesForKeys: [
                                                                .isRegularFileKey
                                                            ],
                                                            options: [
                                                                .skipsHiddenFiles,
                                                                .skipsPackageDescendants
                                                            ])
            guard let filePaths = enumerator?.allObjects as? [URL] else { return }

            // TODO: Optimization
            // This could be optimized further by doing a couple things:
            // - Making sure strings and indexes are using UTF8 everywhere possible
            //   (this will increase matching speed and time taken to calculate byte offsets for string indexes)
            // - Lazily fetching file paths. Right now we do `enumerator.allObjects`, but using an actual
            //   enumerator object to lazily enumerate through files would drop time.
            // - Loop through each character instead of each line to find matches, then return the line if needed.
            //   This could help in cases when the file is one *massive* line (eg: a minified JS document).
            //   In that case this method would load that entire file into memory to find matches. To speed
            //   this up we could enumerate through each character instead of each line and when a match
            //   is found only copy a couple characters into the result object.
            // - Lazily load strings using `FileHandle.AsyncBytes`
            //   https://developer.apple.com/documentation/foundation/filehandle/3766681-bytes
            filePaths.map { url in
                FileSystemClient.FileItem(url: url, children: nil)
            }.forEach { fileItem in
                guard let data = try? Data(contentsOf: fileItem.url),
                let string = String(data: data, encoding: .utf8) else { return }
                var fileSearchResult: SearchResultModel?

                // Loop through each line and look for any matches
                // If one is found we create a `SearchResultModel` and add any lines
                // with matches, and any information we may need to display or navigate
                // to them.
                for (lineNumber, line) in string.split(separator: "\n").lazy.enumerated() {
                    let rawNoSpaceLine = line.trimmingCharacters(in: .whitespacesAndNewlines)
                    let noSpaceLine = ignoreCase ? rawNoSpaceLine.lowercased() : rawNoSpaceLine

                    if lineContainsSearchTerm(line: noSpaceLine, term: textToCompare) {
                        // We've got a match
                        let matches = noSpaceLine.ranges(of: textToCompare).map { range in
                            return SearchResultMatchModel(lineNumber: lineNumber,
                                                          file: fileItem,
                                                          lineContent: String(noSpaceLine),
                                                          keywordRange: range)
                        }
                        if fileSearchResult != nil {
                            // We've already found something in this file, add the rest
                            // of the matches
                            fileSearchResult?.lineMatches.append(contentsOf: matches)
                        } else {
                            // We haven't found anything in this file yet, record a new one
                            fileSearchResult = SearchResultModel(file: fileItem,
                                                                 lineMatches: matches)
                        }
                        searchResultCount += 1
                    }
                }

                // If `fileSearchResult` isn't nil it means we've found matches in the file
                // so we add it to the search results.
                if let fileSearchResult = fileSearchResult {
                    searchResult.append(fileSearchResult)
                }
            }
        }

        /// see if the line contains search term, obeying selectedMode
        ///
        /// - Parameter line: the line to search
        /// - Parameter searchterm: the search term
        /// 
        /// - Returns: whether the line contains the search term
        func lineContainsSearchTerm(line rawLine: String, term searchterm: String) -> Bool {
            // swiftlint:disable:previous cyclomatic_complexity
            var line = rawLine
            if line.hasSuffix(" ") { line.removeLast() }
            if line.hasPrefix(" ") { line.removeFirst() }

            // Text
            let findMode = selectedMode[1]
            if findMode == .Text {
                let textMatching = selectedMode[2]
                let textContainsSearchTerm = line.contains(searchterm)
                guard textContainsSearchTerm == true else { return false }
                guard textMatching != .Containing else { return textContainsSearchTerm }

                // get the index of the search term's appearance in the line
                // and get the characters to the left and right
                let appearances = line.appearancesOfSubstring(substring: searchterm, toLeft: 1, toRight: 1)
                var foundMatch = false
                for appearance in appearances {
                    let appearanceString = String(line[appearance])
                    guard appearanceString.count >= 2,
                          let firstappearanceString = appearanceString.first else { continue }

                    var startsWith = false
                    var endsWith = false
                    if appearanceString.hasPrefix(searchterm) ||
                        !firstappearanceString.isLetter ||
                        !appearanceString.character(at: 2).isLetter {
                        startsWith = true
                    }
                    if appearanceString.hasSuffix(searchterm) ||
                        !firstappearanceString.isLetter ||
                        !appearanceString.character(at: appearanceString.count - 2).isLetter {
                        endsWith = true
                    }

                    switch textMatching {
                    case .MatchingWord:
                        foundMatch = startsWith && endsWith ? true : foundMatch
                    case .StartingWith:
                        foundMatch = startsWith ? true : foundMatch
                    case .EndingWith:
                        foundMatch = endsWith ? true : foundMatch
                    default: continue
                    }
                }
                return foundMatch
            } else if findMode == .RegularExpression {
                guard let regex = try? NSRegularExpression(pattern: searchterm) else { return false }
                // swiftlint:disable:next legacy_constructor
                return regex.firstMatch(in: String(line), range: NSMakeRange(0, line.utf16.count)) != nil
            }

            return false

            // TODO: references and definitions
        }
    }
}

extension String {
    /// Returns the ranges of the substring in the string.
    /// 
    /// - Parameter substring: The substring to search for.
    /// 
    /// - Returns: The ranges of the substring in the string.
    func character(at index: Int) -> Character {
        return self[self.index(self.startIndex, offsetBy: index)]
    }

    /// Returns the ranges of the substring in the string.
    /// 
    /// - Parameter substring: The substring to search for.
    /// - Parameter toLeft: The number of characters to the left of the substring.
    /// - Parameter toRight: The number of characters to the right of the substring.
    /// 
    /// - Returns: The ranges of the substring in the string.
    func appearancesOfSubstring(substring: String, toLeft: Int = 0, toRight: Int = 0) -> [Range<String.Index>] {
        guard !substring.isEmpty && self.contains(substring) else { return [] }
        var appearances: [Range<String.Index>] = []
        for (index, character) in self.enumerated() where character == substring.first {
            let startOfFoundCharacter = self.index(self.startIndex, offsetBy: index)
            guard index + substring.count < self.count else { continue }
            let lengthOfFoundCharacter = self.index(self.startIndex, offsetBy: (substring.count + index))
            if self[startOfFoundCharacter..<lengthOfFoundCharacter] == substring {
                let startIndex = self.index(self.startIndex,
                    offsetBy: index - (toLeft <= index ? toLeft : 0))
                let endIndex = self.index(self.startIndex,
                    offsetBy: substring.count + index +
                        (substring.count + index + toRight <= self.count ? toRight : 0))
                appearances.append(startIndex..<endIndex)
            }
        }
        return appearances
    }
}
