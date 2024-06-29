//
//  GitError.swift
//  Aurora Editor
//
//  Created by Nanashi Li on 2022/08/15.
//  Copyright © 2023 Aurora Company. All rights reserved.
//
//  This source code is restricted for Aurora Editor usage only.
//

import Foundation

/// The git errors which can be parsed from failed git commands.
///
/// NOTE: DON'T MODIFY THE DEFAULT VALUE
enum GitError: String {

    /// SSH Key Audit Unverified
    case SSHKeyAuditUnverified = "ERROR: ([\\s\\S]+?)\\n+\\[EPOLICYKEYAGE\\]\\n+fatal: Could not read from remote repository." // swiftlint:disable:this line_length

    /// SSH Authentication Failed
    case SSHAuthenticationFailed = "fatal: Authentication failed"

    /// SSH Permission Denied
    case SSHPermissionDenied = "fatal: Could not read from remote repository."

    /// HTTPS Authentication Failed
    case HTTPSAuthenticationFailed = "fatal: Authentication failed for 'https://"

    /// Remote disconnected
    case remoteDisconnection = "fatal: [Tt]he remote end hung up unexpectedly"

    /// Host Down
    case hostDown = "Cloning into '(.+)'...\nfatal: unable to access '(.+)': Could not resolve host: (.+)"

    /// Rebasing conflicts
    case rebaseConflicts = "Resolve all conflicts manually, mark them as resolved with"

    /// Merge conflicts
    case mergeConflicts = "(Merge conflict|Automatic merge failed; fix conflicts and then commit the result)"

    /// HTTPS Repository Not Found
    case HTTPSRepositoryNotFound = "fatal: repository '(.+)' not found"

    /// SSH Repository Not Found
    case SSHRepositoryNotFound = "ERROR: Repository not found"

    /// No fast-forward
    case pushNotFastForward = "\\((non-fast-forward|fetch first)\\)\nerror: failed to push some refs to '.*'"

    /// Branch Deletion Failed
    case branchDeletionFailed = "error: unable to delete '(.+)': remote ref does not exist"

    /// Default Branch Deletion Failed
    case defaultBranchDeletionFailed = "\\[remote rejected\\] (.+) \\(deletion of the current branch prohibited\\)" // swiftlint:disable:this line_length

    /// Revert conflicts
    case revertConflicts = "error: could not revert .*\nhint: after resolving the conflicts, mark the corrected paths\nhint: with 'git add <paths>' or 'git rm <paths>'\nhint: and commit the result with 'git commit'" // swiftlint:disable:this line_length

    /// Empty rebase patch
    case emptyRebasePatch = "Applying: .*\nNo changes - did you forget to use 'git add'\\?\nIf there is nothing left to stage, chances are that something else\n.*" // swiftlint:disable:this line_length

    /// No matching remote branch
    case noMatchingRemoteBranch = "There are no candidates for (rebasing|merging) among the refs that you just fetched.\nGenerally this means that you provided a wildcard refspec which had no\nmatches on the remote end." // swiftlint:disable:this line_length

    /// No existing remote branch
    case noExistingRemoteBranch = "Your configuration specifies to merge with the ref '(.+)'\nfrom the remote, but no such ref was fetched." // swiftlint:disable:this line_length

    /// Nothing to commit
    case nothingToCommit = "nothing to commit"

    /// No submodule mapping
    case noSubmoduleMapping = "[Nn]o submodule mapping found in .gitmodules for path '(.+)'"

    /// Submodule repository does not exist
    case submoduleRepositoryDoesNotExist = "fatal: repository '(.+)' does not exist\nfatal: clone of '.+' into submodule path '(.+)' failed" // swiftlint:disable:this line_length

    /// Invalid submodule SHA
    case invalidSubmoduleSHA = "Fetched in submodule path '(.+)', but it did not contain (.+). Direct fetching of that commit failed." // swiftlint:disable:this line_length

    /// Local permission denied
    case localPermissionDenied = "fatal: could not create work tree dir '(.+)'.*: Permission denied" // swiftlint:disable:this line_length

    /// Invalid merge
    case invalidMerge = "merge: (.+) - not something we can merge"

    /// Invalid rebase
    case invalidRebase = "invalid upstream (.+)"

    /// Non fast-forward merge into empty head
    case nonFastForwardMergeIntoEmptyHead = "fatal: Non-fast-forward commit does not make sense into an empty head" // swiftlint:disable:this line_length

    /// Patch does not apply
    case patchDoesNotApply = "error: (.+): (patch does not apply|already exists in working directory)" // swiftlint:disable:this line_length

    /// Branch already exists
    case branchAlreadyExists = "fatal: [Aa] branch named '(.+)' already exists.?"

    /// Bad revision
    case badRevision = "fatal: bad revision '(.*)'"

    /// Not a git repository
    case notAGitRepository = "fatal: not a git repository (or any of the parent directories)" // swiftlint:disable:this line_length

    /// Cannot merge unrelated histories
    case cannotMergeUnrelatedHistories = "fatal: refusing to merge unrelated histories"

    /// LFS attribute does not match
    case LFSAttributeDoesNotMatch = "The .+ attribute should be .+ but is .+"

    /// Branch rename failed
    case branchRenameFailed = "fatal: Branch rename failed"

    /// Path does not exist
    case pathDoesNotExist = "fatal: path '(.+)' does not exist .+"

    /// Invalid object name
    case invalidObjectName = "fatal: invalid object name '(.+)'."

    /// Outside repository
    case outsideRepository = "fatal: .+: '(.+)' is outside repository"

    /// Lock file already exists
    case lockFileAlreadyExists = "Another git process seems to be running in this repository, e.g." // swiftlint:disable:this line_length

    /// No merge to abort
    case noMergeToAbort = "fatal: There is no merge to abort"

    /// Local changes overwritten
    case localChangesOverwritten = "error: (?:Your local changes to the following|The following untracked working tree) files would be overwritten by checkout:" // swiftlint:disable:this line_length

    /// Unresolved conflicts
    case unresolvedConflicts = "You must edit all merge conflicts and then\nmark them as resolved using git add|fatal: Exiting because of an unresolved conflict" // swiftlint:disable:this line_length

    /// GPG failed to sign data
    case GPGFailedToSignData = "error: gpg failed to sign the data"

    /// Conflict modify deleted in branch
    case conflictModifyDeletedInBranch = "CONFLICT \\(modify/delete\\): (.+) deleted in (.+) and modified in (.+)" // swiftlint:disable:this line_length
    // Start of GitHub-specific error codes

    /// Push with file size exceeding limit
    case pushWithFileSizeExceedingLimit = "error: GH001: "

    /// Branch name rejected
    case hexBranchNameRejected = "error: GH002: "

    /// Force push rejected
    case forcePushRejected = "error: GH003: Sorry, force-pushing to (.+) is not allowed."

    /// Invalid reference length
    case invalidRefLength = "error: GH005: Sorry, refs longer than (.+) bytes are not allowed" // swiftlint:disable:this line_length

    /// Protected branch update failed
    case protectedBranchRequiresReview = "error: GH006: Protected branch update failed for (.+)\nremote: error: At least one approved review is required" // swiftlint:disable:this line_length

    /// Protected branch update failed
    case protectedBranchForcePush = "error: GH006: Protected branch update failed for (.+)\nremote: error: Cannot force-push to a protected branch" // swiftlint:disable:this line_length

    /// Protected branch update failed
    case protectedBranchDeleteRejected = "error: GH006: Protected branch update failed for (.+)\nremote: error: Cannot delete a protected branch" // swiftlint:disable:this line_length

    /// Protected branch update failed
    case protectedBranchRequiredStatus = "error: GH006: Protected branch update failed for (.+).\nremote: error: Required status check \"(.+)\" is expected" // swiftlint:disable:this line_length

    /// Push with private email
    case pushWithPrivateEmail = "error: GH007: Your push would publish a private email address." // swiftlint:disable:this line_length
    // End of GitHub-specific error codes

    /// Config lock file already exists
    case configLockFileAlreadyExists = "error: could not lock config file (.+): File exists"

    /// Remote already exists
    case remoteAlreadyExists = "error: remote (.+) already exists."

    /// Tag already exists
    case tagAlreadyExists = "fatal: tag '(.+)' already exists"

    /// Merge with local changes
    case mergeWithLocalChanges = "error: Your local changes to the following files would be overwritten by merge:\n" // swiftlint:disable:this line_length

    /// Rebase with local changes
    case rebaseWithLocalChanges = "error: cannot (pull with rebase|rebase): You have unstaged changes\\.\n\\s*error: [Pp]lease commit or stash them\\." // swiftlint:disable:this line_length

    /// Merge commit no mainline option
    case mergeCommitNoMainlineOption = "error: commit (.+) is a merge but no -m option was given" // swiftlint:disable:this line_length

    /// Unsafe directory
    case unsafeDirectory = "fatal: detected dubious ownership in repository at (.+)"

    /// Path exists but not in ref
    case pathExistsButNotInRef = "fatal: path '(.+)' exists on disk, but not in '(.+)'"
}

/// The error code for when git cannot be found. This most likely indicates a
/// problem with AE
let gitNotFoundErrorCode = "git-not-found-error"

/// The error code for when the path to a repository doesn't exist.
let repositoryDoesNotExistErrorCode = "repository-does-not-exist-error"
