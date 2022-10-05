//
//  GitLog.swift
//  AuroraEditor
//
//  Created by Nanashi Li on 2022/09/08.
//  Copyright © 2022 Aurora Company. All rights reserved.
//

import Foundation

enum CommitDate: String {
    case lastDay = "Last 24 Hours"
    case lastSevenDays = "Last 7 Days"
    case lastThirtyDays = "Last 30 Days"
}

/// Get the repository's commits using `revisionRange` and limited to `limit`
func getCommits(directoryURL: URL,
                revisionRange: String = "",
                limit: Int,
                skip: Int = 0,
                additionalArgs: [String] = [],
                commitsSince: CommitDate? = nil,
                getMerged: Bool = true) throws -> [CommitHistory] {
    var args: [String] = ["log"]

    if !getMerged {
        args.append("--no-merges")
    }

    if !revisionRange.isEmpty {
        args.append(revisionRange)
    }

    // Testing not sure if it works yet
    if commitsSince != nil {
        switch commitsSince {
        case .lastDay:
            args.append("--since=\"24 hours ago\"")
        case .lastSevenDays:
            args.append("--since=\"7 days ago\"")
        case .lastThirtyDays:
            args.append("--since=\"30 days ago\"")
        case .none:
            return []
        }
    }

    if limit > 0 {
        args.append("--max-count=\(limit)")
    }

    if skip > 0 {
        args.append("--skip=\(skip)")
    }

    // %H = SHA
    // %h = short SHA
    // %s = summary
    // %b = body
    // %an = author name
    // %ae = author email
    // %ad = author date
    // %cn = commiter name
    // %ce = comitter email
    // %cd = comitter date
    args.append("--pretty=%H¦%h¦%s¦%an¦%ae¦%ad¦%cn¦%ce¦%cd¦%D")

    let result = try ShellClient().run(
        "cd \(directoryURL.relativePath.escapedWhiteSpaces());git \(args.joined(separator: " "))"
    )

    Log.debug("cd \(directoryURL.relativePath.escapedWhiteSpaces());git \(args.joined(separator: " "))")

    return try result.split(separator: "\n")
        .map { line -> CommitHistory in
            let parameters = line.components(separatedBy: "¦")
            return CommitHistory(
                hash: String(parameters[safe: 1] ?? ""),
                commitHash: String(parameters[safe: 0] ?? ""),
                message: String(parameters[safe: 2] ?? ""),
                author: String(parameters[safe: 3] ?? ""),
                authorEmail: String(parameters[safe: 4] ?? ""),
                commiter: String(parameters[safe: 6] ?? ""),
                commiterEmail: String(parameters[safe: 7] ?? ""),
                remoteURL: URL(string: try Remote().getRemoteURL(directoryURL: directoryURL,
                                                             name: "origin")!),
                date: Date().gitDateFormat(commitDate: String(parameters[safe: 5] ?? "")) ?? Date(),
                isMerge: parameters[safe: 2]?.contains("Merge pull request") ?? false
            )
        }
}
