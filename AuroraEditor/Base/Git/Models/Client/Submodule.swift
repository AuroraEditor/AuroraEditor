//
//  Submodule.swift
//  AuroraEditor
//
//  Created by Nanashi Li on 2022/08/13.
//  Copyright © 2022 Aurora Company. All rights reserved.
//  This source code is restricted for Aurora Editor usage only.
//

import Foundation

func listSubmodules(directoryURL: URL,
                    paths: [String]) throws -> [SubmoduleEntry] {
    let submodulesFile = FileManager.default.fileExists(atPath: "\(directoryURL).gitmodules")
    var isDirectory: ObjCBool = true
    let submodulesDir = FileManager.default.fileExists(atPath: "\(directoryURL).git/modules", isDirectory: &isDirectory)

    if !submodulesFile && !submodulesDir {
        Log.info("No submodules found. Skipping \"git submodule status\"")
        return []
    }

    if paths.isEmpty {
        // unable to parse submodules in repository, giving up
        return []
    }

    // We don't recurse when listing submodules here because we don't have a good
    // story about managing these currently. So for now we're only listing
    // changes to the top-level submodules to be consistent with `git status`
    let result = try ShellClient.live().run(
        "cd \(directoryURL.relativePath.escapedWhiteSpaces());git submodule update --recursive --force --\(paths)")

    var submodules: [SubmoduleEntry] = []

    // entries are of the format:
    //  1eaabe34fc6f486367a176207420378f587d3b48 git (v2.16.0-rc0)
    //
    // first character:
    //   - " " if no change
    //   - "-" if the submodule is not initialized
    //   - "+" if the currently checked out submodule commit does not match the SHA-1 found
    //         in the index of the containing repository
    //   - "U" if the submodule has merge conflicts
    //
    // then the 40-character SHA represents the current commit
    //
    // then the path to the submodule
    //
    // then the output of `git describe` for the submodule in braces
    // we're not leveraging this in the app, so go and read the docs
    // about it if you want to learn more:
    //
    // https://git-scm.com/docs/git-describe
    let statusRe = "/^.([^ ]+) (.+) \\((.+?)\\)$/gm"

    if result.contains(statusRe) {
        for module in result {
            submodules.append(SubmoduleEntry(sha: module.description,
                                             path: module.description,
                                             describe: module.description))
        }
    }

    return submodules
}

func resetSubmodulePaths(directoryURL: URL,
                         paths: [String]) throws {
    if paths.isEmpty {
        return
    }

    try ShellClient().run(
        "cd \(directoryURL.relativePath.escapedWhiteSpaces());git submodule update --recursive --force --\(paths)")
}

class SubmoduleEntry {
    let sha: String
    let path: String
    let describe: String

    init(sha: String, path: String, describe: String) {
        self.sha = sha
        self.path = path
        self.describe = describe
    }
}
