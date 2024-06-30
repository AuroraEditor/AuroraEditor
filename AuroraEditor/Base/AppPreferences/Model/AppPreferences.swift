//
//  AppPreferences.swift
//  Aurora Editor
//
//  Created by Nanashi Li on 29.06.24.
//  Copyright © 2023 Aurora Company. All rights reserved.
//

import SwiftUI

public struct AppPreferences: Codable {
    /// The general global setting
    var general: GeneralPreferences = .init() {
        didSet {
            GeneralPreferences.saveOrUpdate(general)
        }
    }
    /// The global settings for text editing
    var accounts: AccountPreferences = .init()

    /// The global settings for themes
    var theme: ThemePreferences = .init() {
        didSet {
            ThemePreferences.saveOrUpdate(theme)
        }
    }
    /// The global settings for the terminal emulator
    var terminal: TerminalPreferences = .init() {
        didSet {
            TerminalPreferences.saveOrUpdate(terminal)
        }
    }
    /// The global settings for text editing
    var textEditing: TextEditingPreferences = .init() {
        didSet {
            TextEditingPreferences.saveOrUpdate(textEditing)
        }
    }
    /// The global settings for editor font
    var editorFont: EditorFontPreferences = .init() {
        didSet {
            EditorFontPreferences.saveOrUpdate(editorFont)
        }
    }
    /// The global settings for text editing
    var sourceControlGeneral: SourceControlGeneral = .init() {
        didSet {
            SourceControlGeneral.saveOrUpdate(sourceControlGeneral)
        }
    }
    /// The global settings for text editing
    var sourceControlGit: SourceControlGit = .init() {
        didSet {
            SourceControlGit.saveOrUpdate(sourceControlGit)
        }
    }
    var updates: UpdatePreferences = .init() {
        didSet {
            NotificationsPreferences.saveOrUpdate(notifications)
        }
    }
    /// The global settings for the notification system
    var notifications: NotificationsPreferences = .init() {
        didSet {
            NotificationsPreferences.saveOrUpdate(notifications)
        }
    }

    /// Default initializer
    init(databasePath: String) { // swiftlint:disable:this function_body_length
        let dbQueue = try? AppPreferencesDatabase.setupDatabase(at: databasePath)
        if let dbQueue = dbQueue {
            self.general = {
                try? dbQueue.read {
                    database in try GeneralPreferences.fetchOne(
                        // swiftlint:disable:previous closure_parameter_position
                        database
                    )
                }
            }() ?? GeneralPreferences()
            self.accounts = {
                try? dbQueue.read {
                    database in try AccountPreferences.fetchOne(
                        // swiftlint:disable:previous closure_parameter_position
                        database
                    )
                }
            }() ?? AccountPreferences()
            self.theme = {
                try? dbQueue.read {
                    database in try ThemePreferences.fetchOne(
                        // swiftlint:disable:previous closure_parameter_position
                        database
                    )
                }
            }() ?? ThemePreferences()
            self.terminal = {
                try? dbQueue.read {
                    database in try TerminalPreferences.fetchOne(
                        // swiftlint:disable:previous closure_parameter_position
                        database
                    )
                }
            }() ?? TerminalPreferences()
            self.textEditing = {
                try? dbQueue.read {
                    database in try TextEditingPreferences.fetchOne(
                        // swiftlint:disable:previous closure_parameter_position
                        database
                    )
                }
            }() ?? TextEditingPreferences()
            self.editorFont = {
                try? dbQueue.read {
                    database in try EditorFontPreferences.fetchOne(
                        // swiftlint:disable:previous closure_parameter_position
                        database
                    )
                }
            }() ?? EditorFontPreferences()
            self.updates = {
                try? dbQueue.read {
                    database in try UpdatePreferences.fetchOne(
                        // swiftlint:disable:previous closure_parameter_position
                        database
                    )
                }
            }() ?? UpdatePreferences()
            self.sourceControlGeneral = {
                try? dbQueue.read {
                    database in try SourceControlGeneral.fetchOne(
                        // swiftlint:disable:previous closure_parameter_position
                        database
                    )
                }
            }() ?? SourceControlGeneral()
            self.sourceControlGit = {
                try? dbQueue.read {
                    database in try SourceControlGit.fetchOne(
                        // swiftlint:disable:previous closure_parameter_position
                        database
                    )
                }
            }() ?? SourceControlGit()
            self.notifications = {
                try? dbQueue.read {
                    database in try NotificationsPreferences.fetchOne(
                        // swiftlint:disable:previous closure_parameter_position
                        database
                    )
                }
            }() ?? NotificationsPreferences()
        }
    }
}
