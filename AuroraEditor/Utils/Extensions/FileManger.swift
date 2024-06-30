//
//  FileManger.swift
//  Aurora Editor
//
//  Created by Nanashi Li on 2022/08/16.
//  Copyright © 2023 Aurora Company. All rights reserved.
//

import Foundation

extension FileManager {
    /// Check if directory exists at path
    ///
    /// - Parameter path: path
    ///
    /// - Returns: true if directory exists
    func directoryExistsAtPath(_ path: String) -> Bool {
        var isDirectory: ObjCBool = true
        let exists = self.fileExists(
            atPath: "file://\(path)",
            isDirectory: &isDirectory
        )
        return exists && isDirectory.boolValue
    }

    /// Returns the base URL for the Aurora Editor application's support directory.
    ///
    /// This URL points to `~/Library/Application Support/com.auroraeditor/`.
    var auroraEditorBaseURL: URL {
        guard let url = try? self.url(
            for: .applicationSupportDirectory,
            in: .userDomainMask,
            appropriateFor: nil,
            create: true
        ) else {
            return self.homeDirectoryForCurrentUser
                .appendingPathComponent("Library")
                .appendingPathComponent("Application Support")
                .appendingPathComponent("com.auroraeditor")
        }

        return url.appendingPathComponent("com.auroraeditor", isDirectory: true)
    }

    /// Returns the path to the preferences SQLite database file used by the Aurora Editor.
    ///
    /// - Throws: An `NSError` if the application support directory is not found.
    /// - Returns: The file path to the preferences SQLite database.
    static func preferencesDatabasePath() throws -> String {
        let applicationSupportURLs = FileManager.default.urls(
            for: .applicationSupportDirectory,
            in: .userDomainMask
        )
        guard let firstURL = applicationSupportURLs.first else {
            throw NSError(
                domain: "FileManager",
                code: 0,
                userInfo: [NSLocalizedDescriptionKey: "Application support directory not found"]
            )
        }

        let databaseFolderURL = firstURL.appendingPathComponent(
            "com.auroraeditor",
            isDirectory: true
        )
        let databaseFileURL = databaseFolderURL.appendingPathComponent("preferences.sqlite")
        return databaseFileURL.path
    }
}
