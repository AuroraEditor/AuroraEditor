//
//  Revert.swift
//  AuroraEditor
//
//  Created by Nanashi Li on 2022/08/13.
//  Copyright © 2022 Aurora Company. All rights reserved.
//  This source code is restricted for Aurora Editor usage only.
//

import Foundation

/// Creates a new commit that reverts the changes of a previous commit
///
/// @param sha - The SHA of the commit to be reverted
func revertCommit(directoryURL: URL,
                  commit: GitCommit,
                  progressCallback: RevertProgress?) throws {
    var args: [Any] = [gitNetworkArguments, "revert"]

    if (commit.coAuthors?.count)! > 1 {
        args.append("-m")
        args.append("1")
    }

}
