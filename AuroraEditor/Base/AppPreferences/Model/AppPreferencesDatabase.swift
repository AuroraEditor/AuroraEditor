//
//  AppPreferencesDatabase.swift
//  Aurora Editor
//
//  Created by Nanashi Li on 2024/06/29.
//  Copyright © 2024 Aurora Company. All rights reserved.
//

import GRDB
import Foundation
import OSLog

/// Struct responsible for database operations related to application preferences.
struct AppPreferencesDatabase { // swiftlint:disable:this convenience_type type_body_length

    /// Logger for database-related operations.
    static let logger = Logger(subsystem: "com.auroraeditor", category: "App Preferences Database")

    /// Sets up the database queue and creates necessary tables if they do not exist.
    ///
    /// - Parameter path: The file path where the SQLite database should be located.
    /// - Returns: A `DatabaseQueue` instance ready for use.
    static func setupDatabase(at path: String) throws -> DatabaseQueue {
        let dbQueue = try DatabaseQueue(path: path)
        try createTables(in: dbQueue)
        return dbQueue
    }

    /// Creates tables for various preferences using the provided database queue.
    ///
    /// - Parameter dbQueue: The `DatabaseQueue` instance to execute table creation.
    private static func createTables(in dbQueue: DatabaseQueue) throws { // swiftlint:disable:this function_body_length
        do {
            try dbQueue.write { database in
                do {
                    try database.create(
                        table: GeneralPreferences.databaseTableName,
                        ifNotExists: true
                    ) { table in
                        table.primaryKey(["id"])
                        table.column("id", .integer).notNull().defaults(
                            to: 1
                        )
                        table.column("appAppearance", .text).defaults(
                            to: Appearances.system.rawValue
                        )
                        table.column("showIssues", .text).defaults(
                            to: Issues.inline.rawValue
                        )
                        table.column("showLiveIssues", .boolean).defaults(
                            to: true
                        )
                        table.column("fileExtensionsVisibility", .text).defaults(
                            to: FileExtensionsVisibility.showAll.rawValue
                        )
                        table.column("shownFileExtensions", .text).defaults(
                            to: FileExtensions.default.string
                        )
                        table.column("hiddenFileExtensions", .text).defaults(
                            to: FileExtensions.default.string
                        )
                        table.column("fileIconStyle", .text).defaults(
                            to: FileIconStyle.color.rawValue
                        )
                        table.column("tabBarStyle", .text).defaults(
                            to: TabBarStyle.xcode.rawValue
                        )
                        table.column("sidebarStyle", .text).defaults(
                            to: SidebarStyle.xcode.rawValue
                        )
                        table.column("menuItemShowMode", .text).defaults(
                            to: MenuBarShow.shown.rawValue
                        )
                        table.column("reopenBehavior", .text).defaults(
                            to: ReopenBehavior.welcome.rawValue
                        )
                        table.column("projectNavigatorSize", .text).defaults(
                            to: ProjectNavigatorSize.medium.rawValue
                        )
                        table.column("findNavigatorDetail", .integer).defaults(
                            to: NavigatorDetail.upTo3.rawValue
                        )
                        table.column("issueNavigatorDetail", .integer).defaults(
                            to: NavigatorDetail.upTo3.rawValue
                        )
                        table.column("revealFileOnFocusChange", .boolean).defaults(
                            to: false
                        )
                        table.column("keepInspectorSidebarOpen", .boolean).defaults(
                            to: false
                        )
                        table.column("workspaceSidebarWidth", .double).defaults(
                            to: GeneralPreferences.defaultWorkspaceSidebarWidth
                        )
                        table.column("navigationSidebarWidth", .double).defaults(
                            to: GeneralPreferences.defaultNavigationSidebarWidth
                        )
                        table.column("inspectorSidebarWidth", .double).defaults(
                            to: GeneralPreferences.defaultInspectorSidebarWidth
                        )
                    }
                } catch {
                    logger.error("Failed to create GeneralPreferences table: \(error.localizedDescription)")
                }

                do {
                    try database.create(
                        table: AccountPreferences.databaseTableName,
                        ifNotExists: true
                    ) { table in
                        table.column("id", .text).primaryKey()
                        table.column("provider", .text).notNull()
                        table.column("providerLink", .text).notNull()
                        table.column("providerDescription", .text).notNull()
                        table.column("accountName", .text).notNull()
                        table.column("accountEmail", .text).notNull()
                        table.column("accountUsername", .text).notNull()
                        table.column("accountImage", .text).defaults(
                            to: ""
                        )
                        table.column("gitCloningProtocol", .boolean).defaults(
                            to: false
                        )
                        table.column("gitSSHKey", .text).defaults(
                            to: ""
                        )
                        table.column("isTokenValid", .boolean).defaults(
                            to: false
                        )
                    }
                } catch {
                    logger.error("Failed to create AccountPreferences table: \(error.localizedDescription)")
                }

                do {
                    try database.create(
                        table: ThemePreferences.databaseTableName,
                        ifNotExists: true
                    ) { table in
                        table.primaryKey(["id"])
                        table.column("id", .integer).notNull().defaults(
                            to: 1
                        )
                        table.column("selectedTheme", .text).defaults(
                            to: ""
                        )
                        table.column("useThemeBackground", .boolean).defaults(
                            to: true
                        )
                        table.column("mirrorSystemAppearance", .boolean).defaults(
                            to: true
                        )
                        table.column("overrides", .jsonText).defaults(
                            to: "[]"
                        )
                    }
                } catch {
                    logger.error("Failed to create ThemePreferences table: \(error.localizedDescription)")
                }

                do {
                    try database.create(
                        table: TerminalPreferences.databaseTableName,
                        ifNotExists: true
                    ) { table in
                        table.primaryKey(["id"])
                        table.column("id", .integer).notNull().defaults(
                            to: 1
                        )
                        table.column("darkAppearance", .boolean).defaults(
                            to: false
                        )
                        table.column("optionAsMeta", .boolean).defaults(
                            to: false
                        )
                        table.column("shell", .text).defaults(
                            to: TerminalShell.system.rawValue
                        )
                        table.column("cursorStyle", .text).defaults(
                            to: TerminalCursorStyle.block.rawValue
                        )
                        table.column("blinkCursor", .boolean).defaults(
                            to: false
                        )
                        table.column("customTerminalFont", .boolean).defaults(
                            to: false
                        )
                        table.column("terminalFontSize", .integer).defaults(
                            to: 11
                        )
                        table.column("terminalFontName", .text).defaults(
                            to: "SFMono-Medium"
                        )
                    }
                } catch {
                    logger.error("Failed to create TerminalPreferences table: \(error.localizedDescription)")
                }

                do {
                    try database.create(
                        table: TextEditingPreferences.databaseTableName,
                        ifNotExists: true
                    ) { table in
                        table.primaryKey(["id"])
                        table.column("id", .integer).notNull().defaults(
                            to: 1
                        )
                        table.column("defaultTabWidth", .integer).defaults(
                            to: 4
                        )
                        table.column("showMinimap", .boolean).defaults(
                            to: false
                        )
                        table.column("showScopes", .boolean).defaults(
                            to: false
                        )
                        table.column("enableTypeOverCompletion", .boolean).defaults(
                            to: true
                        )
                        table.column("autocompleteBraces", .boolean).defaults(
                            to: true
                        )
                    }
                } catch {
                    logger.error("Failed to create TextEditingPreferences table: \(error.localizedDescription)")
                }

                do {
                    try database.create(
                        table: EditorFontPreferences.databaseTableName,
                        ifNotExists: true
                    ) { table in
                        table.primaryKey(["id"])
                        table.column("id", .integer).notNull().defaults(to: 1)
                        table.column("customFont", .boolean).defaults(to: false)
                        table.column("size", .integer).defaults(to: 11)
                        table.column("name", .text).defaults(to: "SFMono-Medium")
                    }
                } catch {
                    logger.error("Failed to create EditorFontPreferences table: \(error.localizedDescription)")
                }

                do {
                    try database.create(
                        table: SourceControlGeneral.databaseTableName,
                        ifNotExists: true
                    ) { table in
                        table.primaryKey(["id"])
                        table.column("id", .integer).notNull().defaults(
                            to: 1
                        )
                        table.column("enableSourceControl", .boolean).defaults(
                            to: true
                        )
                        table.column("refreshStatusLocaly", .boolean).defaults(
                            to: false
                        )
                        table.column("fetchRefreshServerStatus", .boolean).defaults(
                            to: false
                        )
                        table.column("addRemoveAutomatically", .boolean).defaults(
                            to: false
                        )
                        table.column("selectFilesToCommit", .boolean).defaults(
                            to: false
                        )
                        table.column("showSourceControlChanges", .boolean).defaults(
                            to: true
                        )
                        table.column("includeUpstreamChanges", .boolean).defaults(
                            to: false
                        )
                        table.column("openFeedbackInBrowser", .boolean).defaults(
                            to: true
                        )
                        table.column("revisionComparisonLayout", .text).defaults(
                            to: RevisionComparisonLayout.localLeft.rawValue
                        )
                        table.column("controlNavigatorOrder", .text).defaults(
                            to: ControlNavigatorOrder.sortByName.rawValue
                        )
                        table.column("defaultBranchName", .text).defaults(
                            to: "main"
                        )
                    }
                } catch {
                    logger.error("Failed to create SourceControlGeneral table: \(error.localizedDescription)")
                }

//                do {
//                    let databaseQueue = try DatabaseQueue.fetchDatabase()
//                    try SourceControlGit.create(in: databaseQueue)
//                } catch {
//                    logger.error("Failed to create SourceControlGit table: \(error.localizedDescription)")
//                }

                do {
                    try database.create(
                        table: UpdatePreferences.databaseTableName,
                        ifNotExists: true
                    ) { table in
                        table.primaryKey(["id"])
                        table.column("id", .integer).notNull().defaults(
                            to: 1
                        )
                        table.column("checkForUpdates", .boolean).notNull().defaults(
                            to: true
                        )
                        table.column("downloadUpdatesWhenAvailable", .boolean).notNull().defaults(
                            to: true
                        )
                        table.column("updateChannel", .text).notNull().defaults(
                            to: "release"
                        )
                        table.column("lastChecked", .datetime).notNull().defaults(
                            to: Date()
                        )
                    }
                } catch {
                    logger.error("Failed to create UpdatePreferences table: \(error.localizedDescription)")
                }

                do {
                    try database.create(
                        table: NotificationsPreferences.databaseTableName,
                        ifNotExists: true
                    ) { table in
                        table.column("id", .integer).primaryKey()
                        table.column("notificationsEnabled", .boolean).defaults(
                            to: true
                        )
                        table.column("notificationDisplayTime", .integer).defaults(
                            to: 5000
                        )
                        table.column("doNotDisturb", .boolean).defaults(
                            to: false
                        )
                        table.column("allProfiles", .boolean).defaults(
                            to: false
                        )
                    }
                } catch {
                    logger.error("Failed to create NotificationsPreferences table: \(error.localizedDescription)")
                }
            }
        } catch {
            logger.error("Failed to write to database: \(error.localizedDescription)")
            throw error
        }
    }
}
