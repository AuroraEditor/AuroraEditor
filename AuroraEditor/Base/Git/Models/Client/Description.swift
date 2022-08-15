//
//  Description.swift
//  AuroraEditor
//
//  Created by Nanashi Li on 2022/08/13.
//  Copyright © 2022 Aurora Company. All rights reserved.
//  This source code is restricted for Aurora Editor usage only.
//

import Foundation

let gitDescriptionPath = ".git/description"

let defaultGitDescription = "Unnamed repository; edit this file 'description' to name the repository.\n"

/// Get the project's description from the .git/description file.
func getGitDescription(directoryURL: URL) throws -> String {
    let path = try String(contentsOf: directoryURL) + gitDescriptionPath

    do {
        let data = try String(contentsOf: URL(string: path)!)
        if data == defaultGitDescription {
            return ""
        }
        return data
    } catch {
        return ""
    }
}

/// Write a .git/description file to the project git folder.
func writeGitDescription(directoryURL: URL,
                         description: String) throws {
    let fullPath = try String(contentsOf: directoryURL) + gitDescriptionPath
    try description.write(toFile: fullPath, atomically: false, encoding: .utf8)
}
