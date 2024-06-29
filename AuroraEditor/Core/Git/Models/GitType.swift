//
//  GitType.swift
//  Aurora Editor
//
//  Created by Nanashi Li on 2022/05/20.
//  Copyright © 2023 Aurora Company. All rights reserved.
//

import Foundation

// Used to determine the git type
public enum GitType: String, Codable {
    /// Modified
    case modified = "M"

    /// Unknown
    case unknown = "??"

    /// File type change
    case fileTypeChange = "T"

    /// Added
    case added = "A"

    /// Deleted
    case deleted = "D"

    /// Renamed
    case renamed = "R"

    /// Copied
    case copied = "C"

    /// Updated unmerged
    case updatedUnmerged = "U"

    /// Ignored
    case ignored = "!"

    /// Unchanged
    case unchanged = "."

    /// Description
    var description: String {
        switch self {
        case .modified: return "M"
        case .unknown: return "?"
        case .fileTypeChange: return "T"
        case .added: return "A"
        case .deleted: return "D"
        case .renamed: return "R"
        case .copied: return "C"
        case .updatedUnmerged: return "U"
        case .ignored: return "!"
        case .unchanged: return "."
        }
    }
}

/// The enum representation of a Git file change in Aurora Editor.
enum FileStatusKind: String {
    /// New file
    case new = "New"

    /// Modified file
    case modified = "Modified"

    /// Deleted file
    case deleted = "Deleted"

    /// Copied file
    case copied = "Copied"

    /// Renamed file
    case renamed = "Renamed"

    /// Conflicted file
    case conflicted = "Conflicted"

    /// Untracked file
    case untracked = "Untracked"
}

/// The enum representation of a Git file change in Aurora Editor.
enum UnmergedEntrySummary: String {
    /// Added by us
    case addedByUs = "added-by-us"

    /// Deleted by us
    case deletedByUs = "deleted-by-us"

    /// Added by them
    case addedByThem = "added-by-them"

    /// Deleted by them
    case deletedByThem = "deleted-by-them"

    /// Both deleted
    case bothDeleted = "both-deleted"

    /// Both added
    case bothAdded = "both-added"

    /// Both modified
    case bothModified = "both-modified"
}

/// The porcelain status for an unmerged entry
/// 
/// - Returns: The porcelain status for an unmerged entry
func untrackedEntry() -> String {
    return "untracked"
}
