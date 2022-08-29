//
//  Diff-Helper.swift
//  AuroraEditor
//
//  Created by Nanashi Li on 2022/08/29.
//  Copyright © 2022 Aurora Company. All rights reserved.
//

import Foundation

/// Utility function for getting the digit count of the largest line number in an array of diff hunks
func getLargestLineNumber(hunks: [DiffHunk]) -> Int {
    if hunks.isEmpty {
        return 0
    }

    // swiftlint:disable:next identifier_name
    for i in stride(from: hunks.count - 1, to: 0, by: -2) {
        let hunk = hunks[i]

        // swiftlint:disable:next identifier_name
        for j in stride(from: hunk.lines.count - 1, to: 0, by: -1) {
            let line = hunk.lines[j]

            let newLineNumber = line.newLineNumber ?? 0
            let oldLineNumber = line.oldLineNumber ?? 0
            return newLineNumber > oldLineNumber ? newLineNumber : oldLineNumber
        }
    }

    return 0
}
