//
//  SourceControlPreferences.swift
//  Aurora Editor
//
//  Created by Nanashi Li on 2022/04/08.
//  Copyright © 2023 Aurora Company. All rights reserved.
//

import Foundation
import GRDB

struct SourceControlGeneral: Codable, FetchableRecord, PersistableRecord, DatabaseValueConvertible {
    public var id: Int64 = 1
    /// Indicates whether or not the source control is active
    public var enableSourceControl: Bool = true
    /// Indicates whether or not we should include the upsteam changes
    public var refreshStatusLocaly: Bool = false
    /// Indicates whether or not we should include the upsteam changes
    public var fetchRefreshServerStatus: Bool = false
    /// Indicates whether or not we should include the upsteam changes
    public var addRemoveAutomatically: Bool = false
    /// Indicates whether or not we should include the upsteam changes
    public var selectFilesToCommit: Bool = false
    /// Indicates whether or not to show the source control changes
    public var showSourceControlChanges: Bool = true
    /// Indicates whether or not we should include the upsteam
    public var includeUpstreamChanges: Bool = false
    /// Indicates whether or not we should open the reported feedback in the browser
    public var openFeedbackInBrowser: Bool = true
    /// The selected value of the comparison view
    public var revisionComparisonLayout: RevisionComparisonLayout = .localLeft
    /// The selected value of the control navigator
    public var controlNavigatorOrder: ControlNavigatorOrder = .sortByName
    /// The name of the default branch
    public var defaultBranchName: String = "main"

    static let databaseTableName = "SourceControlGeneralPreferences"
}

struct SourceControlGit: Codable, FetchableRecord, PersistableRecord, DatabaseValueConvertible {
    public var id: Int64 = 1
    /// The author name
    public var authorName: String = ""
    /// The author email
    public var authorEmail: String = ""
    /// Indicates what files should be ignored when commiting
    public var ignoredFiles: [IgnoredFiles] = []
    /// Indicates whether we should rebase when pulling commits
    public var preferRebaseWhenPulling: Bool = false
    /// Indicates whether we should show commits per file log
    public var showMergeCommitsPerFileLog: Bool = false

    static let databaseTableName = "SourceControlGitPreferences"

    enum CodingKeys: String, CodingKey {
        case id
        case authorName
        case authorEmail
        case ignoredFiles
        case preferRebaseWhenPulling
        case showMergeCommitsPerFileLog
    }

    enum Columns {
        static let id = Column(CodingKeys.id)
        static let authorName = Column(CodingKeys.authorName)
        static let authorEmail = Column(CodingKeys.authorEmail)
        static let preferRebaseWhenPulling = Column(CodingKeys.preferRebaseWhenPulling)
        static let showMergeCommitsPerFileLog = Column(CodingKeys.showMergeCommitsPerFileLog)
        static let ignoredFiles = Column("ignoredFiles")
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(authorName, forKey: .authorName)
        try container.encode(authorEmail, forKey: .authorEmail)
        try container.encode(preferRebaseWhenPulling, forKey: .preferRebaseWhenPulling)
        try container.encode(showMergeCommitsPerFileLog, forKey: .showMergeCommitsPerFileLog)
        try container.encode(ignoredFiles, forKey: .ignoredFiles)
    }

    init() {}

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(Int64.self, forKey: .id)
        authorName = try container.decode(String.self, forKey: .authorName)
        authorEmail = try container.decode(String.self, forKey: .authorEmail)
        preferRebaseWhenPulling = try container.decode(Bool.self, forKey: .preferRebaseWhenPulling)
        showMergeCommitsPerFileLog = try container.decode(Bool.self, forKey: .showMergeCommitsPerFileLog)
        ignoredFiles = try container.decode([IgnoredFiles].self, forKey: .ignoredFiles)
    }

    // MARK: - PersistableRecord conformance

    func encode(to container: inout PersistenceContainer) {
        container[CodingKeys.id.rawValue] = id
        container[CodingKeys.authorName.rawValue] = authorName
        container[CodingKeys.authorEmail.rawValue] = authorEmail
        container[CodingKeys.preferRebaseWhenPulling.rawValue] = preferRebaseWhenPulling
        container[CodingKeys.showMergeCommitsPerFileLog.rawValue] = showMergeCommitsPerFileLog

        // Convert ignoredFiles to JSON string for database storage
        let jsonData = try? JSONEncoder().encode(ignoredFiles)
        container[CodingKeys.ignoredFiles.rawValue] = jsonData.flatMap { String(data: $0, encoding: .utf8) } ?? "[]"
    }

    // MARK: - FetchableRecord conformance

    init(row: Row) {
        id = row[CodingKeys.id.rawValue] ?? 1
        authorName = row[CodingKeys.authorName.rawValue] ?? ""
        authorEmail = row[CodingKeys.authorEmail.rawValue] ?? ""
        preferRebaseWhenPulling = row[CodingKeys.preferRebaseWhenPulling.rawValue] ?? false
        showMergeCommitsPerFileLog = row[CodingKeys.showMergeCommitsPerFileLog.rawValue] ?? false

        // Convert JSON string back to [IgnoredFiles]
        if let jsonString = row[CodingKeys.ignoredFiles.rawValue] as String?,
           let jsonData = jsonString.data(using: .utf8),
           let decodedIgnoredFiles = try? JSONDecoder().decode([IgnoredFiles].self, from: jsonData) {
            ignoredFiles = decodedIgnoredFiles
        } else {
            ignoredFiles = []
        }
    }

    static func create(in dbQueue: DatabaseQueue) throws {
        try dbQueue.write { database in
            try database.create(table: SourceControlGit.databaseTableName, ifNotExists: true) { table in
                table.column(Columns.id.name, .integer).notNull().primaryKey()
                table.column(Columns.authorName.name, .text).defaults(to: "")
                table.column(Columns.authorEmail.name, .text).defaults(to: "")
                table.column(Columns.preferRebaseWhenPulling.name, .boolean).defaults(to: false)
                table.column(Columns.showMergeCommitsPerFileLog.name, .boolean).defaults(to: false)
                table.column(Columns.ignoredFiles.name, .text).defaults(to: "[]")
            }
        }
    }
}

/// The style for control Navigator
/// - **sortName**: They are sorted by Name
/// - **sortDate**: They are sorted by Date
enum ControlNavigatorOrder: String, Codable {
    /// They are sorted by Name
    case sortByName

    /// They are sorted by Date
    case sortByDate
}

/// The style for comparison View
/// - **localLeft**: Local Revision on Left Side
/// - **localRight**: Local Revision on Right Side
enum RevisionComparisonLayout: String, Codable {
    /// Local Revision on Left Side
    case localLeft

    /// Local Revision on Right Side
    case localRight
}
