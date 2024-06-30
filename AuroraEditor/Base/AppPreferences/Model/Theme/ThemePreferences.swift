//
//  ThemePreferences.swift
//  Aurora Editor
//
//  Created by Nanashi Li on 2022/04/08.
//  Copyright © 2023 Aurora Company. All rights reserved.
//

import Foundation
import GRDB

typealias ThemeOverrides = [String: [String: AuroraTheme.Attributes]]

/// The global settings for themes
struct ThemePreferences: Codable, FetchableRecord, PersistableRecord, DatabaseValueConvertible {

    public var id: Int64 = 1

    /// The name of the currently selected theme
    public var selectedTheme: String? = ""

    /// Use the system background that matches the appearance setting
    public var useThemeBackground: Bool = true

    /// Automatically change theme based on system appearance
    public var mirrorSystemAppearance: Bool = true

    /// Dictionary of themes containing overrides
    public var overrides: [String: ThemeOverrides] = [:]

    static let databaseTableName = "ThemePreferences"

    /// Default initializer
    public init() {}
}
