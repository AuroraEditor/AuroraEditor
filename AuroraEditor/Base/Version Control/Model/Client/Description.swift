//
//  Description.swift
//  Aurora Editor
//
//  Created by Nanashi Li on 2022/08/13.
//  Copyright © 2023 Aurora Company. All rights reserved.
//
//  This source code is restricted for Aurora Editor usage only.
//

import Foundation

/// The path to the .git/description file.
let gitDescriptionPath = ".git/description"

/// The default content of the .git/description file.
let defaultGitDescription = "Unnamed repository; edit this file 'description' to name the repository.\n"

/// Get the project's description from the .git/description file.
/// 
/// - Parameter directoryURL: The directory to look up the description in.
/// 
/// - Returns: The description of the project.
/// 
/// - Throws: Error
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
/// 
/// - Parameter directoryURL: The directory to write the description to.
/// - Parameter description: The description to write.
/// 
/// - Throws: Error
func writeGitDescription(directoryURL: URL,
                         description: String) throws {
    let fullPath = try String(contentsOf: directoryURL) + gitDescriptionPath
    try description.write(toFile: fullPath, atomically: false, encoding: .utf8)
}
