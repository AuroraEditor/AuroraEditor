//
//  Init.swift
//  AuroraEditor
//
//  Created by Nanashi Li on 2022/08/13.
//  Copyright © 2022 Aurora Company. All rights reserved.
//

import Foundation

public struct Init {

    /// Init a new git repository in the given path.
    func initGitRepository(directoryURL: URL) throws {
        _ = try ShellClient.live().run(
            // swiftlint:disable:next line_length
            "cd \(directoryURL.relativePath.escapedWhiteSpaces());git -c init.defailtBranch=\(DefaultBranch().getDefaultBranch()) init"
        )
    }
}
