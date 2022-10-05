//
//  Code.swift
//  AuroraEditor
//
//  Created by Nanashi Li on 2022/08/15.
//  Copyright © 2022 Aurora Company. All rights reserved.
//  This source code is restricted for Aurora Editor usage only.
//

import Foundation

/// Return an array of command line arguments for network operation that override
/// the default git configuration values provided by local, global, or system
/// level git configs.
///
/// These arguments should be inserted before the subcommand, i.e in the case of
/// git pull` these arguments needs to go before the `pull` argument.
var gitNetworkArguments: [String] {
    // Explicitly unset any defined credential helper, we rely on our
    // own askpass for authentication.
    ["-c", "credential.helper="]
}

/// Returns the arguments to use on any git operation that can end up
/// triggering a rebase.
func gitRebaseArguments() -> [String] {
    // Explicitly set the rebase backend to merge.
    // We need to force this option to be sure that AE
    // uses the merge backend even if the user has the apply backend
    // configured, since this is the only one supported.
    // This can go away once git deprecates the apply backend.
    return ["-c", "rebase.backend=merge"]
}

/// Returns the SHA of the passed in IGitResult
func parseCommitSHA(result: String) -> String {
    return String(result.split(separator: "]")[0].split(separator: " ")[1])
}
