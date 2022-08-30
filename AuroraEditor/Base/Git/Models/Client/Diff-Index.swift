//
//  Diff-Index.swift
//  AuroraEditor
//
//  Created by Nanashi Li on 2022/08/29.
//  Copyright © 2022 Aurora Company. All rights reserved.
//

import Foundation

/// Possible statuses of an entry in Git
enum IndexStatus: Int {
    case unknown = 0
    case added
    case copied
    case deleted
    case modified
    case renamed
    case typeChanged
    case unmerged
}

typealias NoRenameIndexStatus = IndexStatus

func getIndexStatus(status: String) throws -> IndexStatus {
    switch status.substring(0) {
    case "A":
        return IndexStatus.added
    case "C":
        return IndexStatus.copied
    case "D":
        return IndexStatus.deleted
    case "M":
        return IndexStatus.modified
    case "R":
        return IndexStatus.renamed
    case "T":
        return IndexStatus.typeChanged
    case "U":
        return IndexStatus.unmerged
    case "X":
        return IndexStatus.unknown
    default:
        throw IndexError.unknownIndex("Unknown index status: \(status)")
    }
}

func getNoRenameIndexStatus(status: String) throws -> NoRenameIndexStatus {
    let parsed = try getIndexStatus(status: status)

    switch parsed {
    case .copied, .renamed:
        throw IndexError.noRenameIndex("Invalid index status for no-rename index status: \(parsed)")
    case .unknown:
        return .unknown
    case .added:
        return .added
    case .deleted:
        return .deleted
    case .modified:
        return .modified
    case .typeChanged:
        return .typeChanged
    case .unmerged:
        return .unmerged
    }
}

/// The SHA for the nil tree
let nilTreeSHA = "4b825dc642cb6eb9a060e54bf8d69288fbee4904"

func getIndexChanges(directoryURL: URL) throws -> [String: NoRenameIndexStatus] {
    let args = ["diff-index", "--cahced", "name-status", "--no-renames", "-z"]

    let result = try ShellClient().run(
        "cd \(directoryURL.relativePath.escapedWhiteSpaces());git \(args)"
    )

    var map: [String: NoRenameIndexStatus] = [:]

    let pieces = result.split(separator: "\0")

    // swiftlint:disable:next identifier_name
    for i in stride(from: 0, to: pieces.count, by: 2) {
        let status = try getNoRenameIndexStatus(status: String(pieces[i]))
        let path = pieces[i + 1]

        map = [String(path): status]
    }

    return map
}

enum IndexError: Error {
    case unknownIndex(String)
    case noRenameIndex(String)
}
