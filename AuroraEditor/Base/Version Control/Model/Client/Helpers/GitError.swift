//
//  GitError.swift
//  AuroraEditor
//
//  Created by Nanashi Li on 2022/08/15.
//  Copyright © 2022 Aurora Company. All rights reserved.
//  This source code is restricted for Aurora Editor usage only.
//

import Foundation

/// The git errors which can be parsed from failed git commands.
///
/// NOTE: DON'T MODIFY THE DEFAULT VALUE
enum GitError: String {
    case SSHKeyAuditUnverified = "ERROR: ([\\s\\S]+?)\\n+\\[EPOLICYKEYAGE\\]\\n+fatal: Could not read from remote repository." // swiftlint:disable:this line_length
    case SSHAuthenticationFailed = "fatal: Authentication failed"
    case SSHPermissionDenied = "fatal: Could not read from remote repository."
    case HTTPSAuthenticationFailed = "fatal: Authentication failed for 'https://"
    case remoteDisconnection = "fatal: [Tt]he remote end hung up unexpectedly"
    case hostDown = "Cloning into '(.+)'...\nfatal: unable to access '(.+)': Could not resolve host: (.+)"
    case rebaseConflicts = "Resolve all conflicts manually, mark them as resolved with"
    case mergeConflicts = "(Merge conflict|Automatic merge failed; fix conflicts and then commit the result)"
    case HTTPSRepositoryNotFound = "fatal: repository '(.+)' not found"
    case SSHRepositoryNotFound = "ERROR: Repository not found"
    case pushNotFastForward = "\\((non-fast-forward|fetch first)\\)\nerror: failed to push some refs to '.*'"
    case branchDeletionFailed = "error: unable to delete '(.+)': remote ref does not exist"
    case defaultBranchDeletionFailed = "\\[remote rejected\\] (.+) \\(deletion of the current branch prohibited\\)" // swiftlint:disable:this line_length
    case revertConflicts = "error: could not revert .*\nhint: after resolving the conflicts, mark the corrected paths\nhint: with 'git add <paths>' or 'git rm <paths>'\nhint: and commit the result with 'git commit'" // swiftlint:disable:this line_length
    case emptyRebasePatch = "Applying: .*\nNo changes - did you forget to use 'git add'\\?\nIf there is nothing left to stage, chances are that something else\n.*" // swiftlint:disable:this line_length
    case noMatchingRemoteBranch = "There are no candidates for (rebasing|merging) among the refs that you just fetched.\nGenerally this means that you provided a wildcard refspec which had no\nmatches on the remote end." // swiftlint:disable:this line_length
    case noExistingRemoteBranch = "Your configuration specifies to merge with the ref '(.+)'\nfrom the remote, but no such ref was fetched." // swiftlint:disable:this line_length
    case nothingToCommit = "nothing to commit"
    case noSubmoduleMapping = "[Nn]o submodule mapping found in .gitmodules for path '(.+)'"
    case submoduleRepositoryDoesNotExist = "fatal: repository '(.+)' does not exist\nfatal: clone of '.+' into submodule path '(.+)' failed" // swiftlint:disable:this line_length
    case invalidSubmoduleSHA = "Fetched in submodule path '(.+)', but it did not contain (.+). Direct fetching of that commit failed." // swiftlint:disable:this line_length
    case localPermissionDenied = "fatal: could not create work tree dir '(.+)'.*: Permission denied" // swiftlint:disable:this line_length
    case invalidMerge = "merge: (.+) - not something we can merge"
    case invalidRebase = "invalid upstream (.+)"
    case nonFastForwardMergeIntoEmptyHead = "fatal: Non-fast-forward commit does not make sense into an empty head" // swiftlint:disable:this line_length
    case patchDoesNotApply = "error: (.+): (patch does not apply|already exists in working directory)" // swiftlint:disable:this line_length
    case branchAlreadyExists = "fatal: [Aa] branch named '(.+)' already exists.?"
    case badRevision = "fatal: bad revision '(.*)'"
    case notAGitRepository = "fatal: not a git repository (or any of the parent directories)" // swiftlint:disable:this line_length
    case cannotMergeUnrelatedHistories = "fatal: refusing to merge unrelated histories"
    case LFSAttributeDoesNotMatch = "The .+ attribute should be .+ but is .+"
    case branchRenameFailed = "fatal: Branch rename failed"
    case pathDoesNotExist = "fatal: path '(.+)' does not exist .+"
    case invalidObjectName = "fatal: invalid object name '(.+)'."
    case outsideRepository = "fatal: .+: '(.+)' is outside repository"
    case lockFileAlreadyExists = "Another git process seems to be running in this repository, e.g." // swiftlint:disable:this line_length
    case noMergeToAbort = "fatal: There is no merge to abort"
    case localChangesOverwritten = "error: (?:Your local changes to the following|The following untracked working tree) files would be overwritten by checkout:" // swiftlint:disable:this line_length
    case unresolvedConflicts = "You must edit all merge conflicts and then\nmark them as resolved using git add|fatal: Exiting because of an unresolved conflict" // swiftlint:disable:this line_length
    case GPGFailedToSignData = "error: gpg failed to sign the data"
    case conflictModifyDeletedInBranch = "CONFLICT \\(modify/delete\\): (.+) deleted in (.+) and modified in (.+)" // swiftlint:disable:this line_length
    // Start of GitHub-specific error codes
    case pushWithFileSizeExceedingLimit = "error: GH001: "
    case hexBranchNameRejected = "error: GH002: "
    case forcePushRejected = "error: GH003: Sorry, force-pushing to (.+) is not allowed."
    case invalidRefLength = "error: GH005: Sorry, refs longer than (.+) bytes are not allowed" // swiftlint:disable:this line_length
    case protectedBranchRequiresReview = "error: GH006: Protected branch update failed for (.+)\nremote: error: At least one approved review is required" // swiftlint:disable:this line_length
    case protectedBranchForcePush = "error: GH006: Protected branch update failed for (.+)\nremote: error: Cannot force-push to a protected branch" // swiftlint:disable:this line_length
    case protectedBranchDeleteRejected = "error: GH006: Protected branch update failed for (.+)\nremote: error: Cannot delete a protected branch" // swiftlint:disable:this line_length
    case protectedBranchRequiredStatus = "error: GH006: Protected branch update failed for (.+).\nremote: error: Required status check \"(.+)\" is expected" // swiftlint:disable:this line_length
    case pushWithPrivateEmail = "error: GH007: Your push would publish a private email address." // swiftlint:disable:this line_length
    // End of GitHub-specific error codes
    case configLockFileAlreadyExists = "error: could not lock config file (.+): File exists"
    case remoteAlreadyExists = "error: remote (.+) already exists."
    case tagAlreadyExists = "fatal: tag '(.+)' already exists"
    case mergeWithLocalChanges = "error: Your local changes to the following files would be overwritten by merge:\n" // swiftlint:disable:this line_length
    case rebaseWithLocalChanges = "error: cannot (pull with rebase|rebase): You have unstaged changes\\.\n\\s*error: [Pp]lease commit or stash them\\." // swiftlint:disable:this line_length
    case mergeCommitNoMainlineOption = "error: commit (.+) is a merge but no -m option was given" // swiftlint:disable:this line_length
    case unsafeDirectory = "fatal: detected dubious ownership in repository at (.+)"
    case pathExistsButNotInRef = "fatal: path '(.+)' exists on disk, but not in '(.+)'"
}

/// The error code for when git cannot be found. This most likely indicates a
/// problem with AE
let gitNotFoundErrorCode = "git-not-found-error"

/// The error code for when the path to a repository doesn't exist.
let repositoryDoesNotExistErrorCode = "repository-does-not-exist-error"
