//
//  Init.swift
//  Aurora Editor
//
//  Created by Nanashi Li on 2022/08/13.
//  Copyright © 2023 Aurora Company. All rights reserved.
//
//  This source code is restricted for Aurora Editor usage only.
//

import Foundation

/// Init a new git repository in the given path.
func initGitRepository(directoryURL: URL) throws {
    try ShellClient().run(
        // swiftlint:disable:next line_length
        "cd \(directoryURL.relativePath.escapedWhiteSpaces());git -c init.defaultBranch=\(DefaultBranch().getDefaultBranch()) init"
    )
}
