//
//  AppPreferencesModel.swift
//  Aurora Editor
//
//  Created by Nanashi Li on 29.06.24.
//  Copyright © 2023 Aurora Company. All rights reserved.
//

import Foundation
import GRDB
import Combine
import OSLog

/// Manages application preferences stored in a SQLite database
/// and provides reactive updates to observed properties.
///
/// Use this class to access and modify various application preferences 
/// such as general settings, theme preferences, source control configurations, and more.
public final class AppPreferencesModel: ObservableObject {
    /// Shared instance of `AppPreferencesModel` to provide a singleton access.
    public static let shared: AppPreferencesModel = .init()

    /// Path to the SQLite database file storing application preferences.
    private let databasePath: String

    /// Database queue used to perform database operations.
    private var dbQueue: DatabaseQueue?

    /// Set of cancellable Combine subscriptions to manage observation lifetimes.
    private var cancellables = Set<AnyCancellable>()

    /// Published property exposing application preferences to trigger UI updates.
    @Published public var preferences: AppPreferences

    /// Logger instance for logging preference-related activities.
    let logger = Logger(subsystem: "com.auroraeditor", category: "AppPreferencesModel")

    /// Private initializer to set up the database path, initialize preferences, and observe database changes.
    private init() {
        guard let applicationSupport = FileManager.default
            .urls(for: .applicationSupportDirectory, in: .userDomainMask)
            .first else {
            fatalError("Cannot find Application Support Directory")
        }

        self.databasePath = applicationSupport
            .appendingPathComponent("com.auroraeditor")
            .appendingPathComponent("preferences.sqlite")
            .path

        self.dbQueue = try? AppPreferencesDatabase.setupDatabase(at: databasePath)
        self.preferences = AppPreferences(databasePath: databasePath)
        setupDatabaseObservers()
    }

    /// Deinitializer to cancel all Combine subscriptions.
    deinit {
        cancellables.forEach { $0.cancel() }
    }

    /// Sets up observers for various preference categories
    /// to reactively update `preferences` on database changes.
    private func setupDatabaseObservers() { // swiftlint:disable:this function_body_length
        guard let dbQueue = dbQueue else { return }

        setupObserver(
            for: \.general,
            defaultValue: GeneralPreferences(),
            fetchOne: GeneralPreferences.fetchOne,
            in: dbQueue
        )
        setupObserver(
            for: \.accounts,
            defaultValue: AccountPreferences(),
            fetchOne: AccountPreferences.fetchOne,
            in: dbQueue
        )
        setupObserver(
            for: \.theme,
            defaultValue: ThemePreferences(),
            fetchOne: ThemePreferences.fetchOne,
            in: dbQueue
        )
        setupObserver(
            for: \.terminal,
            defaultValue: TerminalPreferences(),
            fetchOne: TerminalPreferences.fetchOne,
            in: dbQueue
        )
        setupObserver(
            for: \.textEditing,
            defaultValue: TextEditingPreferences(),
            fetchOne: TextEditingPreferences.fetchOne,
            in: dbQueue
        )
        setupObserver(
            for: \.editorFont,
            defaultValue: EditorFontPreferences(),
            fetchOne: EditorFontPreferences.fetchOne,
            in: dbQueue
        )
        setupObserver(
            for: \.sourceControlGeneral,
            defaultValue: SourceControlGeneral(),
            fetchOne: SourceControlGeneral.fetchOne,
            in: dbQueue
        )
        setupObserver(
            for: \.sourceControlGit,
            defaultValue: SourceControlGit(),
            fetchOne: SourceControlGit.fetchOne,
            in: dbQueue
        )
        setupObserver(
            for: \.updates,
            defaultValue: UpdatePreferences(),
            fetchOne: UpdatePreferences.fetchOne,
            in: dbQueue
        )
        setupObserver(
            for: \.notifications,
            defaultValue: NotificationsPreferences(),
            fetchOne: NotificationsPreferences.fetchOne,
            in: dbQueue
        )
    }

    /// Sets up a Combine observer for a specific preference category.
    ///
    /// - Parameters:
    ///   - keyPath: Key path to the preference category within `AppPreferences`.
    ///   - defaultValue: Default value if database fetch fails.
    ///   - fetchOne: Closure to fetch the preference value from the database.
    ///   - dbQueue: Database queue to perform the fetch operation.
    private func setupObserver<T: DatabaseValueConvertible & FetchableRecord>(
        for keyPath: WritableKeyPath<AppPreferences, T>,
        defaultValue: T,
        fetchOne: @escaping (Database) throws -> T?,
        in dbQueue: DatabaseQueue
    ) {
        ValueObservation
            .tracking(fetchOne)
            .publisher(in: dbQueue)
            .replaceError(with: nil)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] value in
                self?.preferences[keyPath: keyPath] = value ?? defaultValue
                self?.objectWillChange.send()
            }
            .store(in: &cancellables)
    }

    public func sourceControlActive() -> Bool {
        preferences.sourceControlGeneral.enableSourceControl
    }
}
