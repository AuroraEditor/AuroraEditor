//
//  Format-Patch.swift
//  Aurora Editor
//
//  Created by Nanashi Li on 2022/08/13.
//  Copyright © 2023 Aurora Company. All rights reserved.
//
//  This source code is restricted for Aurora Editor usage only.
//

import Foundation

/// Generate a patch representing the changes associated with a range of commits
/// 
/// - Parameter directoryURL: The directory to generate the patch in.
/// - Parameter base: The commit to start the patch from.
/// - Parameter head: The commit to end the patch at.
/// 
/// - Returns: The patch as a string.
/// 
/// - Throws: Error
func formatPatch(directoryURL: URL,
                 base: String,
                 head: String) throws -> String {
    let result = try ShellClient.live().run(
        "cd \(directoryURL.relativePath.escapedWhiteSpaces());git format-path --unified=1 --minimal --stdout"
    )

    return result
}
