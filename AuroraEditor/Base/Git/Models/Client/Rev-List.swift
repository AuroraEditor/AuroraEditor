//
//  Rev-List.swift
//  AuroraEditor
//
//  Created by Nanashi Li on 2022/08/17.
//  Copyright © 2022 Aurora Company. All rights reserved.
//

import Foundation

/// Convert two refs into the Git range syntax representing the set of commits
/// that are reachable from `to` but excluding those that are reachable from
/// `from`. This will not be inclusive to the `from` ref, see
/// `revRangeInclusive`.
///
/// Each parameter can be the commit SHA or a ref name, or specify an empty
/// string to represent HEAD.
// swiftlint:disable:next identifier_name
func revRange(from: String, to: String) -> String {
    return "\(from)..\(to)"
}

/// Convert two refs into the Git range syntax representing the set of commits
/// that are reachable from `to` but excluding those that are reachable from
/// `from`. However as opposed to `revRange`, this will also include `from` ref.
///
/// Each parameter can be the commit SHA or a ref name, or specify an empty
/// string to represent HEAD.
// swiftlint:disable:next identifier_name
func revRangeInclusive(from: String, to: String) -> String {
    return "\(from)^...\(to)"
}

/// Convert two refs into the Git symmetric difference syntax, which represents
/// the set of commits that are reachable from either `from` or `to` but not
/// from both.
///
/// Each parameter can be the commit SHA or a ref name, or you can use an empty
/// string to represent HEAD.
// swiftlint:disable:next identifier_name
func revSymmetricDifference(from: String, to: String) -> String {
    return "\(from)...\(to)"
}

/// Calculate the number of commits the range is ahead and behind.
func getAheadBehind(directoryURL: URL,
                    range: String) throws -> AheadBehind? {
    // `--left-right` annotates the list of commits in the range with which side
    // they're coming from. When used with `--count`, it tells us how many
    // commits we have from the two different sides of the range.
    let args = ["rev-list", "--left-right", "--count", range, "--"]

    let result = try ShellClient().run(
        "cd \(directoryURL.relativePath.escapedWhiteSpaces());git \(args)"
    )

    // This means one of the refs (most likely the upstream branch) no longer
    // exists. In that case we can't be ahead/behind at all.
    if result.contains(GitError.badRevision.rawValue) {
        return nil
    }

    let pieces = result.split(separator: "\t")

    if pieces.count != 2 {
        return nil
    }

    let ahead = Int(pieces[0], radix: 10)
    if ahead != nil {
        return nil
    }

    let behind = Int(pieces[1], radix: 10)
    if behind != nil {
        return nil
    }

    return AheadBehind(ahead: ahead!, behind: behind!)
}

func getBranchAheadBehind(directoryURL: URL,
                          branch: String) {
}

/// Get a list of commits from the target branch that do not exist on the base
/// branch, ordered how they will be applied to the base branch.
/// Therefore, this will not include the baseBranchSha commit.
///
/// This emulates how `git rebase` initially determines what will be applied to
/// the repository.
///
/// Returns `nil` when the rebase is not possible to perform, because of a
/// missing commit ID
func getCommitsBetweenCommits(directoryURL: URL,
                              baseBranchSha: String,
                              targetBranchSha: String) throws -> [CommitOneLine]? {
    let range = revRange(from: baseBranchSha, to: targetBranchSha)
    return try getCommitsInRange(directoryURL: directoryURL, range: range)
}

/// Get a list of commits inside the provided range.
///
/// Returns `nil` when it is not possible to perform because of a bad range.
func getCommitsInRange(directoryURL: URL,
                       range: String) throws -> [CommitOneLine]? {

    let args = [
        "rev-list",
        range,
        "--reverse",
        // the combination of these two arguments means each line of the stdout
        // will contain the full commit sha and a commit summary
        "--oneline",
        "--no-abbrev-commit",
        "--"
    ]

    let result = try ShellClient().run(
        "cd \(directoryURL.relativePath.escapedWhiteSpaces());git \(args)"
    )

    if result.contains(GitError.badRevision.rawValue) {
        return nil
    }

    var commits: [CommitOneLine] = []

    if result.count == 3 {
        let sha = result.substring(1)
        let summary = result.substring(2)

        commits.append(CommitOneLine(sha: sha, summary: summary))
    }

    return commits
}
