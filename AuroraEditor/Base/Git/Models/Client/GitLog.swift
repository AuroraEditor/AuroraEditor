//
//  GitLog.swift
//  AuroraEditor
//
//  Created by Nanashi Li on 2022/09/08.
//  Copyright © 2022 Aurora Company. All rights reserved.
//

import Foundation

/// Get the repository's commits using `revisionRange` and limited to `limit`
func getCommits(directoryURL: URL,
                revisionRange: String = "",
                limit: Int,
                skip: Int = 0,
                additionalArgs: [String] = []) throws -> [CommitHistory] {
    var args: [String] = ["log"]

    if !revisionRange.isEmpty {
        args.append(revisionRange)
    }

    args.append("--date=raw")

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
    args.append("--pretty=%H¦%h¦%s¦%b¦%an¦%ae¦%ad¦%cn¦%ce¦%cd¦%D¦")

    let result = try ShellClient().run(
        "cd \(directoryURL.relativePath.escapedWhiteSpaces());git \(args.joined(separator: ", "))"
    )

    Log.debug(args.joined(separator: ","))
    Log.debug(result.split(separator: "\n"))

    return try result.split(separator: "\n")
        .map { line -> CommitHistory in
            let parameters = line.split(separator: "¦")
            return CommitHistory(
                hash: String(parameters[safe: 1] ?? ""),
                commitHash: String(parameters[safe: 0] ?? ""),
                message: String(parameters[safe: 2] ?? ""),
                author: String(parameters[safe: 4] ?? ""),
                authorEmail: String(parameters[safe: 5] ?? ""),
                commiter: String(parameters[safe: 7] ?? ""),
                commiterEmail: String(parameters[safe: 8] ?? ""),
                remoteURL: URL(string: try Remote().getRemoteURL(directoryURL: directoryURL,
                                                             name: "origin")!),
                date: Date().gitDateFormat(commitDate: String(parameters[safe: 6] ?? "")) ?? Date()
            )
        }
}
