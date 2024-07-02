//
//  GitCommit.swift
//  Aurora Editor
//
//  Created by Nana on 3/10/21.
//  Copyright © 2023 Aurora Company. All rights reserved.
//
//  This source code is restricted for Aurora Editor usage only.
//

import Foundation

/// Grouping of information required to create a commit
protocol ICommitContext {
    /// The summary of the commit message (required)
    var summary: String? { get }

    /// Additional details for the commit message (optional)
    var description: String? { get }

    /// Whether or not it should amend the last commit (optional, default: false)
    var amend: Bool? { get }

    /// An optional array of commit trailers (for example Co-Authored-By trailers)
    /// which will be appended to the commit message in accordance with the Git trailer configuration.
    var trailers: [Trailer]? { get }
}

/// A commit context.
class CommitContext: ICommitContext {
    /// The summary of the commit message.
    var summary: String?

    /// Description of the commit message.
    var description: String?

    /// Whether or not it should amend the last commit.
    var amend: Bool?

    /// An optional array of commit trailers.
    var trailers: [Trailer]?

    /// Initialize a new `CommitContext` instance.
    /// 
    /// - Parameter summary: The summary of the commit message.
    /// - Parameter description: Description of the commit message.
    /// - Parameter amend: Whether or not it should amend the last commit.
    /// - Parameter trailers: An optional array of commit trailers.
    init(summary: String?,
         description: String?,
         amend: Bool?,
         trailers: [Trailer]?) {
        self.summary = summary
        self.description = description
        self.amend = amend
        self.trailers = trailers
    }
}

/// Extract any Co-Authored-By trailers from an array of arbitrary
/// trailers.
/// 
/// - Parameter trailers: The array of trailers to search.
/// 
/// - Returns: An array of GitAuthors parsed from the Co-Authored-By trailers.
func extractCoAuthors(trailers: [Trailer]) -> [GitAuthor] {
    var coAuthors: [GitAuthor] = []

    for trailer in trailers where isCoAuthoredByTrailer(trailer: trailer) {
        let author = GitAuthor(name: nil, email: nil).parse(nameAddr: trailer.value)
        if let author = author {
            coAuthors.append(author)
        }
    }

    return coAuthors
}

/// A minimal shape of data to represent a commit, for situations where the
/// application does not require the full commit metadata.
///
/// Equivalent to the output where Git command support the
/// `--oneline --no-abbrev-commit` arguments to format a commit.
class CommitOneLine {
    /// The SHA of the commit.
    var sha: String

    /// The summary of the commit.
    var summary: String

    /// Initialize a new `CommitOneLine` instance.
    /// 
    /// - Parameter sha: The SHA of the commit.
    /// - Parameter summary: The summary of the commit.
    init(sha: String, summary: String) {
        self.sha = sha
        self.summary = summary
    }
}

/// A git commit.
class GitCommit {
    /// A list of co-authors parsed from the commit message
    /// trailers.
    var coAuthors: [GitAuthor]?

    /// The commit body after removing coauthors
    var bodyNoCoAuthors: String?

    /// A value indicating whether the author and the committer
    /// are the same person.
    var authoredByCommitter: Bool

    /// Whether or not the commit is a merge commit (i.e. has at least 2 parents)
    var isMergeCommit: Bool

    /// Initialize a new `GitCommit` instance.
    /// 
    /// - Parameter sha: The SHA of the commit.
    /// - Parameter shortSha: The short SHA of the commit.
    /// - Parameter summary: The summary of the commit.
    /// - Parameter body: The body of the commit.
    /// - Parameter author: The author of the commit.
    /// - Parameter commiter: The committer of the commit.
    /// - Parameter parentShas: The parent SHAs of the commit.
    /// - Parameter trailers: The trailers of the commit.
    /// - Parameter tags: The tags of the commit.
    init(sha: String,
         shortSha: String,
         summary: String,
         body: String,
         author: String,
         commiter: String,
         parentShas: [String],
         trailers: [Trailer],
         tags: [String]) {
        self.coAuthors = extractCoAuthors(trailers: trailers)
        self.authoredByCommitter = false
        self.bodyNoCoAuthors = ""
        self.isMergeCommit = parentShas.count > 1
    }
}
