//
//  Submodule.swift
//  AuroraEditor
//
//  Created by Nanashi Li on 2022/08/13.
//  Copyright © 2022 Aurora Company. All rights reserved.
//

import Foundation

func listSubmodules() {}

func resetSubmodulePaths(directoryURL: URL,
                         paths: [String]) throws {
    if paths.isEmpty {
        return
    }

    _ = try ShellClient.live().run(
        "cd \(directoryURL.relativePath.escapedWhiteSpaces());git submodule update --recursive --force --\(paths)")
}
