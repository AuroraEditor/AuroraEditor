//
//  Revert.swift
//  Aurora Editor
//
//  Created by Nanashi Li on 2022/08/13.
//  Copyright © 2023 Aurora Company. All rights reserved.
//
//  This source code is restricted for Aurora Editor usage only.
//

import Foundation

/// Creates a new commit that reverts the changes of a previous commit
///
/// - Parameter directoryURL: The project url
/// - Parameter commit: The commit to revert
/// - Parameter progressCallback: The progress callback
/// 
/// - Throws: Error
func revertCommit(directoryURL: URL,
                  commit: GitCommit,
                  progressCallback: RevertProgress?) throws {
    var args: [Any] = [gitNetworkArguments, "revert"]

    if (commit.coAuthors?.count)! > 1 {
        args.append("-m")
        args.append("1")
    }

}
