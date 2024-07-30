//
//  TextEditingPreferences.swift
//  Aurora Editor
//
//  Created by Nanashi Li on 2022/04/08.
//  Copyright © 2023 Aurora Company. All rights reserved.
//

import Foundation
import GRDB

/// The global settings for text editing
struct TextEditingPreferences: Codable, FetchableRecord, PersistableRecord, DatabaseValueConvertible {

    public var id: Int64 = 1

    /// An integer indicating how many spaces a `tab` will generate
    public var defaultTabWidth: Int = 4

    /// Indicates whether or not to show scopes
    public var showScopes: Bool = false

    /// Indicates whether or not to enable type over completion
    public var enableTypeOverCompletion: Bool = true

    /// Indicates whether or not to autocomplete braces
    public var autocompleteBraces: Bool = true

    public var isSyntaxHighlightingDisabled: Bool = false

    static let databaseTableName = "TextEditingPreferences"

    /// Default initializer
    public init() {}
}

/// The font to use in the editor
struct EditorFontPreferences: Codable, Equatable, FetchableRecord, PersistableRecord, DatabaseValueConvertible {

    public var id: Int64 = 1

    /// Indicates whether or not to use a custom font
    public var customFont: Bool = false

    /// The font size for the custom font
    public var size: Int = 11

    /// The name of the custom font
    public var name: String = "SFMono-Medium"

    static let databaseTableName = "EditorFontPreferences"

    /// Default initializer
    public init() {}
}
