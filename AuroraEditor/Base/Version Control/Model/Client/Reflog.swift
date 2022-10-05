//
//  Reflog.swift
//  AuroraEditor
//
//  Created by Nanashi Li on 2022/08/13.
//  Copyright © 2022 Aurora Company. All rights reserved.
//  This source code is restricted for Aurora Editor usage only.
//

import Foundation

/// Get the `limit` most recently checked out branches.
func getRecentBranches(directoryURL: URL,
                       limit: Int) throws -> [String] {
    // swiftlint:disable:next line_length
    let regex = "//.*? (renamed|checkout)(?:: moving from|\\s*) (?:refs\\//heads\\//|\\s*)(.*?) to (?:refs\\//heads\\//|\\s*)(.*?)$//i"

    let args = ["log",
    "-g",
    "--no-abbrev-commit",
    "--pretty=oneline",
    "HEAD",
    "-n",
    "2500",
    "--"]

    let result = try ShellClient.live().run(
        "cd \(directoryURL.relativePath.escapedWhiteSpaces());git \(args)")

    let lines = result.split(separator: "\n")
    let names = Set<String>()
    let excludedNames = Set<String>()

    return []
}

let noCommitsOnBranchRe = "fatal: your current branch '.*' does not have any commits yet"

/// Gets the distinct list of branches that have been checked out after a specific date
/// Returns a map keyed on branch names
func getBranchesCheckouts(directoryURL: URL,
                          afterDate: Date) throws -> [String: Date] {
    let regex = "/^[a-z0-9]{40}\\sHEAD@{(.*)}\\scheckout: moving from\\s.*\\sto\\s(.*)$/"

    let result = try ShellClient.live().run(
        // swiftlint:disable:next line_length
        "cd \(directoryURL.relativePath.escapedWhiteSpaces());git reflog --date=iso --after\(afterDate.ISO8601Format()) --pretty=%H %gd %gs --grep-reflog=checkout: moving from .* to .*$ --")

    let checkouts: [String: Date] = [:]

    return checkouts
}
