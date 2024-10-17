//
//  GeneralPreferences.swift
//  Aurora Editor
//
//  Created by Nanashi Li on 2022/04/08.
//  Copyright © 2023 Aurora Company. All rights reserved.
//

import SwiftUI
import OSLog
import GRDB

/// The general global setting
struct GeneralPreferences: Codable, FetchableRecord, PersistableRecord, DatabaseValueConvertible {

    public var id: Int64 = 1

    /// The appearance of the app
    public var appAppearance: Appearances = .system

    /// The show issues behavior of the app
    public var showIssues: Issues = .inline

    /// The show live issues behavior of the app
    public var showLiveIssues: Bool = true

    /// The show file extensions behavior of the app
    public var fileExtensionsVisibility: FileExtensionsVisibility = .showAll

    /// The file extensions collection to display
    public var shownFileExtensions: FileExtensions = .default

    /// The file extensions collection to hide
    public var hiddenFileExtensions: FileExtensions = .default

    /// The style for file icons
    public var fileIconStyle: FileIconStyle = .color

    /// Choose between Xcode-like and VSCode-like sidebar mode selection
    public var sidebarStyle: SidebarStyle = .xcode

    /// Choose between showing and hiding the menu bar accessory
    public var menuItemShowMode: MenuBarShow = .shown

    /// The reopen behavior of the app
    public var reopenBehavior: ReopenBehavior = .welcome

    /// The project navigator size
    public var projectNavigatorSize: ProjectNavigatorSize = .medium

    /// The Find Navigator Detail line limit
    public var findNavigatorDetail: NavigatorDetail = .upTo3

    /// The Issue Navigator Detail line limit
    public var issueNavigatorDetail: NavigatorDetail = .upTo3

    /// The reveal file in navigator when focus changes behavior of the app.
    public var revealFileOnFocusChange: Bool = false

    /// The fag whether inspectors side-bar should open by default or not.
    public var keepInspectorSidebarOpen: Bool = false

    /// The workspace sidebar width
    public var workspaceSidebarWidth: Double = Self.defaultWorkspaceSidebarWidth

    /// The navigation sidebar width
    public var navigationSidebarWidth: Double = Self.defaultNavigationSidebarWidth

    /// The inspector sidebar width
    public var inspectorSidebarWidth: Double = Self.defaultInspectorSidebarWidth

    /// Aurora Editor Window Width
    public var auroraEditorWindowWidth: Double {
        navigationSidebarWidth + workspaceSidebarWidth + inspectorSidebarWidth
    }

    /// Default inspector sidebar width
    static let defaultInspectorSidebarWidth: Double = 260

    /// Default navigation sidebar width
    static let defaultNavigationSidebarWidth: Double = 260

    /// Default workspace sidebar width
    static let defaultWorkspaceSidebarWidth: Double = 260

    static let databaseTableName = "GeneralPreferences"
}

/// The appearance of the app
/// - **system**: uses the system appearance
/// - **dark**: always uses dark appearance
/// - **light**: always uses light appearance
enum Appearances: String, Codable, FetchableRecord, PersistableRecord {
    case system
    case light
    case dark

    /// Applies the selected appearance
    @MainActor
    public func applyAppearance() {
        switch self {
        case .system:
            NSApp.appearance = nil
        case .dark:
            NSApp.appearance = .init(named: .darkAqua)

        case .light:
            NSApp.appearance = .init(named: .aqua)
        }
    }
}

/// The style for issues display
///  - **inline**: Issues show inline
///  - **minimized** Issues show minimized
enum Issues: String, Codable, FetchableRecord, PersistableRecord {
    case inline
    case minimized
}

/// The style for file extensions visibility
///  - **hideAll**: File extensions are hidden
///  - **showAll** File extensions are visible
///  - **showOnly** Specific file extensions are visible
///  - **hideOnly** Specific file extensions are hidden
enum FileExtensionsVisibility: String, Codable, Hashable, FetchableRecord, PersistableRecord {
    case hideAll
    case showAll
    case showOnly
    case hideOnly
}

/// The collection of file extensions used by
/// ``FileExtensionsVisibility/showOnly`` or  ``FileExtensionsVisibility/hideOnly`` preference
struct FileExtensions: Codable, Hashable, FetchableRecord, PersistableRecord {
    /// The file extensions
    public var extensions: [String]

    /// The string representation of the file extensions
    public var string: String {
        get {
            extensions.joined(separator: ", ")
        }
        set {
            extensions = newValue
                .components(separatedBy: ",")
                .map({ $0.trimmingCharacters(in: .whitespacesAndNewlines) })
                .filter({ !$0.isEmpty || string.count < newValue.count })
        }
    }

    /// Default file extensions
    public static let `default` = FileExtensions(extensions: [
        "c", "cc", "cpp", "h", "hpp", "m", "mm", "gif",
        "icns", "jpeg", "jpg", "png", "tiff", "swift"
    ])
}

/// The style for file icons
/// - **color**: File icons appear in their default colors
/// - **monochrome**: File icons appear monochromatic
enum FileIconStyle: String, Codable, FetchableRecord, PersistableRecord {
    /// File icons appear in their default colors
    case color
    /// File icons appear monochromatic
    case monochrome
}

/// The style for the sidebar's mode selection
/// - **xcode**: Xcode-like mode selection
/// - **vscode**: VSCode-like mode seliction
enum SidebarStyle: String, Codable, FetchableRecord, PersistableRecord {
    /// Xcode-like mode selection
    case xcode

    /// VSCode-like mode seliction
    case vscode
}

/// If the menu item should be shwon
/// - **shown**: The menu bar item is shown
/// - **hidden**: The menu bar item is hidden
enum MenuBarShow: String, Codable, FetchableRecord, PersistableRecord {
    /// The menu bar item is shown
    case shown

    /// The menu bar item is hidden
    case hidden
}

/// The reopen behavior of the app
/// - **welcome**: On restart the app will show the welcome screen
/// - **openPanel**: On restart the app will show an open panel
/// - **newDocument**: On restart a new empty document will be created
enum ReopenBehavior: String, Codable, FetchableRecord, PersistableRecord {
    /// On restart the app will show the welcome screen
    case welcome

    /// On restart the app will show an open panel
    case openPanel

    /// On restart a new empty document will be created
    case newDocument
}

/// The size of the project navigator
enum ProjectNavigatorSize: String, Codable, FetchableRecord, PersistableRecord {
    /// The row height of the project navigator
    case small

    /// The row height of the project navigator
    case medium

    /// The row height of the project navigator
    case large

    /// Returns the row height depending on the `projectNavigatorSize` in `AppPreferences`.
    ///
    /// * `small`: 20
    /// * `medium`: 22
    /// * `large`: 24
    public var rowHeight: Double {
        switch self {
        case .small: return 20
        case .medium: return 22
        case .large: return 24
        }
    }
}

/// The Navigation Detail behavior of the app
///  - Use **rawValue** to set lineLimit
enum NavigatorDetail: Int, Codable, CaseIterable, FetchableRecord, PersistableRecord {
    /// One line
    case upTo1 = 1
    /// Up to 2 lines
    case upTo2 = 2
    /// Up to 3 lines
    case upTo3 = 3
    /// Up to 4 lines
    case upTo4 = 4
    /// Up to 5 lines
    case upTo5 = 5
    /// Up to 10 lines
    case upTo10 = 10
    /// Up to 30 lines
    case upTo30 = 30

    /// The label for the line limit
    var label: String {
        switch self {
        case .upTo1:
            return "One Line"
        default:
            return "Up to \(self.rawValue) lines"
        }
    }
}

// Why tf is this here, in a god damn model class? This is stupid omfg!!!
/// Aurora Editor Commandline installation
func aeCommandLine() {
    let logger = Logger(subsystem: "com.auroraeditor", category: "AE Command Line Installer")

    do {
        let url = Bundle.main.url(forResource: "ae", withExtension: nil, subdirectory: "Resources")
        let destination = "/usr/local/bin/ae"

        if FileManager.default.fileExists(atPath: destination) {
            try FileManager.default.removeItem(atPath: destination)
        }

        guard let shellUrl = url?.path else {
            logger.fault("Failed to get URL to shell command")
            return
        }

        NSWorkspace.shared.requestAuthorization(to: .createSymbolicLink) { auth, error in
            guard let auth = auth, error == nil else {
                fallbackShellInstallation(commandPath: shellUrl, destinationPath: destination)
                return
            }

            do {
                try FileManager(authorization: auth).createSymbolicLink(
                    atPath: destination, withDestinationPath: shellUrl
                )
            } catch {
                fallbackShellInstallation(commandPath: shellUrl, destinationPath: destination)
            }
        }
    } catch {
        logger.fault("\(error)")
    }
}

/// Fallback shell installation
func fallbackShellInstallation(commandPath: String, destinationPath: String) {
    let logger = Logger(subsystem: "com.auroraeditor", category: "Fallback Shell Installation")

    let cmd = [
        "osascript",
        "-e",
        "\"do shell script \\\"mkdir -p /usr/local/bin && ln -sf \'\(commandPath)\' \'\(destinationPath)\'\\\"\"",
        "with administrator privileges"
    ]

    let cmdStr = cmd.joined(separator: " ")

    let task = Process()
    let pipe = Pipe()

    task.standardOutput = pipe
    task.standardError = pipe
    task.arguments = ["-c", cmdStr]
    task.executableURL = URL(fileURLWithPath: "/bin/zsh")
    task.standardInput = nil

    do {
        try task.run()
    } catch {
        logger.fault("\(error)")
    }
}
