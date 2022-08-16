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
    case SSHKeyAuditUnverified = "ERROR: ([\\s\\S]+?)\\n+\\[EPOLICYKEYAGE\\]\\n+fatal: Could not read from remote repository."
    case SSHAuthenticationFailed = "fatal: Authentication failed"
    case SSHPermissionDenied = "fatal: Could not read from remote repository."
    case HTTPSAuthenticationFailed = "fatal: Authentication failed for 'https://"
    case RemoteDisconnection = "fatal: [Tt]he remote end hung up unexpectedly"
    case HostDown = "Cloning into '(.+)'...\nfatal: unable to access '(.+)': Could not resolve host: (.+)"
    case RebaseConflicts = "Resolve all conflicts manually, mark them as resolved with"
    case MergeConflicts = "(Merge conflict|Automatic merge failed; fix conflicts and then commit the result)"
    case HTTPSRepositoryNotFound = "fatal: repository '(.+)' not found"
    case SSHRepositoryNotFound = "ERROR: Repository not found"
    case PushNotFastForward = "\\((non-fast-forward|fetch first)\\)\nerror: failed to push some refs to '.*'"
    case BranchDeletionFailed = "error: unable to delete '(.+)': remote ref does not exist"
    case DefaultBranchDeletionFailed = "\\[remote rejected\\] (.+) \\(deletion of the current branch prohibited\\)"
    case RevertConflicts = "error: could not revert .*\nhint: after resolving the conflicts, mark the corrected paths\nhint: with 'git add <paths>' or 'git rm <paths>'\nhint: and commit the result with 'git commit'"
    case EmptyRebasePatch = "Applying: .*\nNo changes - did you forget to use 'git add'\\?\nIf there is nothing left to stage, chances are that something else\n.*"
    case NoMatchingRemoteBranch = "There are no candidates for (rebasing|merging) among the refs that you just fetched.\nGenerally this means that you provided a wildcard refspec which had no\nmatches on the remote end."
    case NoExistingRemoteBranch = "Your configuration specifies to merge with the ref '(.+)'\nfrom the remote, but no such ref was fetched."
    case NothingToCommit = "nothing to commit"
    case NoSubmoduleMapping = "[Nn]o submodule mapping found in .gitmodules for path '(.+)'"
    case SubmoduleRepositoryDoesNotExist = "fatal: repository '(.+)' does not exist\nfatal: clone of '.+' into submodule path '(.+)' failed"
    case InvalidSubmoduleSHA = "Fetched in submodule path '(.+)', but it did not contain (.+). Direct fetching of that commit failed."
    case LocalPermissionDenied = "fatal: could not create work tree dir '(.+)'.*: Permission denied"
    case InvalidMerge = "merge: (.+) - not something we can merge"
    case InvalidRebase = "invalid upstream (.+)"
    case NonFastForwardMergeIntoEmptyHead = "fatal: Non-fast-forward commit does not make sense into an empty head"
    case PatchDoesNotApply = "error: (.+): (patch does not apply|already exists in working directory)"
    case BranchAlreadyExists = "fatal: [Aa] branch named '(.+)' already exists.?"
    case BadRevision = "fatal: bad revision '(.*)'"
    case NotAGitRepository = "fatal: not a git repository (or any of the parent directories)"
    case CannotMergeUnrelatedHistories = "fatal: refusing to merge unrelated histories"
    case LFSAttributeDoesNotMatch = "The .+ attribute should be .+ but is .+"
    case BranchRenameFailed = "fatal: Branch rename failed"
    case PathDoesNotExist = "fatal: path '(.+)' does not exist .+"
    case InvalidObjectName = "fatal: invalid object name '(.+)'."
    case OutsideRepository = "fatal: .+: '(.+)' is outside repository"
    case LockFileAlreadyExists = "Another git process seems to be running in this repository, e.g."
    case NoMergeToAbort = "fatal: There is no merge to abort"
    case LocalChangesOverwritten = "error: (?:Your local changes to the following|The following untracked working tree) files would be overwritten by checkout:"
    case UnresolvedConflicts = "You must edit all merge conflicts and then\nmark them as resolved using git add|fatal: Exiting because of an unresolved conflict"
    case GPGFailedToSignData = "error: gpg failed to sign the data"
    case ConflictModifyDeletedInBranch = "CONFLICT \\(modify/delete\\): (.+) deleted in (.+) and modified in (.+)"
    // Start of GitHub-specific error codes
    case PushWithFileSizeExceedingLimit = "error: GH001: "
    case HexBranchNameRejected = "error: GH002: "
    case ForcePushRejected = "error: GH003: Sorry, force-pushing to (.+) is not allowed."
    case InvalidRefLength = "error: GH005: Sorry, refs longer than (.+) bytes are not allowed"
    case ProtectedBranchRequiresReview = "error: GH006: Protected branch update failed for (.+)\nremote: error: At least one approved review is required"
    case ProtectedBranchForcePush = "error: GH006: Protected branch update failed for (.+)\nremote: error: Cannot force-push to a protected branch"
    case ProtectedBranchDeleteRejected = "error: GH006: Protected branch update failed for (.+)\nremote: error: Cannot delete a protected branch"
    case ProtectedBranchRequiredStatus = "error: GH006: Protected branch update failed for (.+).\nremote: error: Required status check \"(.+)\" is expected"
    case PushWithPrivateEmail = "error: GH007: Your push would publish a private email address."
    // End of GitHub-specific error codes
    case ConfigLockFileAlreadyExists = "error: could not lock config file (.+): File exists"
    case RemoteAlreadyExists = "error: remote (.+) already exists."
    case TagAlreadyExists = "fatal: tag '(.+)' already exists"
    case MergeWithLocalChanges = "error: Your local changes to the following files would be overwritten by merge:\n"
    case RebaseWithLocalChanges = "error: cannot (pull with rebase|rebase): You have unstaged changes\\.\n\\s*error: [Pp]lease commit or stash them\\."
    case MergeCommitNoMainlineOption = "error: commit (.+) is a merge but no -m option was given"
    case UnsafeDirectory = "fatal: detected dubious ownership in repository at (.+)"
    case PathExistsButNotInRef = "fatal: path '(.+)' exists on disk, but not in '(.+)'"
}

/// The error code for when git cannot be found. This most likely indicates a
/// problem with AE
let gitNotFoundErrorCode = "git-not-found-error"

/// The error code for when the path to a repository doesn't exist.
let repositoryDoesNotExistErrorCode = "repository-does-not-exist-error"
