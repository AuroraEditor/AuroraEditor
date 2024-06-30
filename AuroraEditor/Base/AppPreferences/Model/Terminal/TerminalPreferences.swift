//
//  TerminalPreferences.swift
//  Aurora Editor
//
//  Created by Nanashi Li on 2022/04/08.
//  Copyright © 2023 Aurora Company. All rights reserved.
//

import SwiftTerm
import GRDB

/// The global settings for the terminal emulator
struct TerminalPreferences: Codable, FetchableRecord, PersistableRecord, DatabaseValueConvertible {

    public var id: Int64 = 1

    /// If true terminal appearance will always be `dark`. Otherwise it adapts to the system setting.
    public var darkAppearance: Bool = false

    /// If true, the terminal treats the `Option` key as the `Meta` key
    public var optionAsMeta: Bool = false

    /// The selected shell to use.
    public var shell: TerminalShell = .system

    /// The cursor style to apply on the terminal. Defaults to `block`.
    public var cursorStyle: TerminalCursorStyle = .block

    /// Boolean value for whether the cursor should blink.
    public var blinkCursor: Bool = false

    // MARK: - Terminal Font Variable

    /// Indicates whether or not to use a custom font
    public var customTerminalFont: Bool = false

    /// The font size for the custom font
    public var terminalFontSize: Int = 11

    /// The name of the custom font
    public var terminalFontName: String = "SFMono-Medium"

    static let databaseTableName = "TerminalPreferences"

    /// Default initializer
    public init() {}
}

/// The shell options.
/// - **bash**: uses the bash shell
/// - **zsh**: uses the ZSH shell
/// - **system**: uses the system default shell (most likely ZSH)
enum TerminalShell: String, Codable {
    /// Uses the bash shell
    case bash
    /// Uses the ZSH shell
    case zsh
    /// Uses the system default shell (most likely ZSH)
    case system
}

/// The possible terminal cursor shapes.
enum TerminalCursorStyle: String, Codable, CaseIterable, Identifiable {
    /// The unique identifier for the cursor style
    public var id: String { rawValue }
    /// Cursor appears as a block shape █
    case block
    /// Cursor appears as an underline _
    case underline
    /// Cursor appears as a vertical bar |
    case verticalBar = "vertical bar"
}
