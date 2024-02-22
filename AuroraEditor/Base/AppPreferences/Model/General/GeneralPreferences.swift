//
//  GeneralPreferences.swift
//  Aurora Editor
//
//  Created by Nanashi Li on 2022/04/08.
//  Copyright © 2023 Aurora Company. All rights reserved.
//

import SwiftUI

public extension AppPreferences {

    /// The general global setting
    struct GeneralPreferences: Codable {

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

        /// Choose between native-styled tab bar and Xcode-liked tab bar.
        public var tabBarStyle: TabBarStyle = .xcode

        /// Choose between Xcode-like and VSCode-like sidebar mode selection
        public var sidebarStyle: SidebarStyle = .xcode

        /// Choose between showing and hiding the menu bar accessory
        public var menuItemShowMode: MenuBarShow = .shown

        /// The reopen behavior of the app
        public var reopenBehavior: ReopenBehavior = .welcome

        public var projectNavigatorSize: ProjectNavigatorSize = .medium

        /// The Find Navigator Detail line limit
        public var findNavigatorDetail: NavigatorDetail = .upTo3

        /// The Issue Navigator Detail line limit
        public var issueNavigatorDetail: NavigatorDetail = .upTo3

        /// The reveal file in navigator when focus changes behavior of the app.
        public var revealFileOnFocusChange: Bool = false

        /// The fag whether inspectors side-bar should open by default or not.
        public var keepInspectorSidebarOpen: Bool = false

        public var workspaceSidebarWidth: Double = Self.defaultWorkspaceSidebarWidth
        public var navigationSidebarWidth: Double = Self.defaultNavigationSidebarWidth
        public var inspectorSidebarWidth: Double = Self.defaultInspectorSidebarWidth

        public var auroraEditorWindowWidth: Double {
            navigationSidebarWidth + workspaceSidebarWidth + inspectorSidebarWidth
        }

        private static let defaultInspectorSidebarWidth: Double = 260
        private static let defaultNavigationSidebarWidth: Double = 260
        private static let defaultWorkspaceSidebarWidth: Double = 260

        /// Default initializer
        public init() {}

        /// Explicit decoder init for setting default values when key is not present in `JSON`
        public init(from decoder: Decoder) throws { // swiftlint:disable:this function_body_length
            let container = try decoder.container(keyedBy: CodingKeys.self)
            self.appAppearance = try container.decodeIfPresent(
                Appearances.self,
                forKey: .appAppearance
            ) ?? .system
            self.showIssues = try container.decodeIfPresent(
                Issues.self,
                forKey: .showIssues
            ) ?? .inline
            self.showLiveIssues = try container.decodeIfPresent(
                Bool.self,
                forKey: .showLiveIssues
            ) ?? true
            self.fileExtensionsVisibility = try container.decodeIfPresent(
                FileExtensionsVisibility.self,
                forKey: .fileExtensionsVisibility
            ) ?? .showAll
            self.shownFileExtensions = try container.decodeIfPresent(
                FileExtensions.self,
                forKey: .shownFileExtensions
            ) ?? .default
            self.hiddenFileExtensions = try container.decodeIfPresent(
                FileExtensions.self,
                forKey: .hiddenFileExtensions
            ) ?? .default
            self.fileIconStyle = try container.decodeIfPresent(
                FileIconStyle.self,
                forKey: .fileIconStyle
            ) ?? .color
            self.tabBarStyle = try container.decodeIfPresent(
                TabBarStyle.self,
                forKey: .tabBarStyle
            ) ?? .xcode
            self.sidebarStyle = try container.decodeIfPresent(
                SidebarStyle.self,
                forKey: .sidebarStyle
            ) ?? .xcode
            self.menuItemShowMode = try container.decodeIfPresent(
                MenuBarShow.self,
                forKey: .menuItemShowMode
            ) ?? .shown
            self.reopenBehavior = try container.decodeIfPresent(
                ReopenBehavior.self,
                forKey: .reopenBehavior
            ) ?? .welcome
            self.projectNavigatorSize = try container.decodeIfPresent(
                ProjectNavigatorSize.self,
                forKey: .projectNavigatorSize
            ) ?? .medium
            self.findNavigatorDetail = try container.decodeIfPresent(
                NavigatorDetail.self,
                forKey: .findNavigatorDetail
            ) ?? .upTo3
            self.issueNavigatorDetail = try container.decodeIfPresent(
                NavigatorDetail.self,
                forKey: .issueNavigatorDetail
            ) ?? .upTo3
            self.revealFileOnFocusChange = try container.decodeIfPresent(
                Bool.self,
                forKey: .revealFileOnFocusChange
            ) ?? false
            self.keepInspectorSidebarOpen = try container.decodeIfPresent(
                Bool.self,
                forKey: .keepInspectorSidebarOpen
            ) ?? true
            self.navigationSidebarWidth = try container.decodeIfPresent(
                Double.self,
                forKey: .navigationSidebarWidth
            ) ?? Self.defaultNavigationSidebarWidth
            self.workspaceSidebarWidth = try container.decodeIfPresent(
                Double.self,
                forKey: .workspaceSidebarWidth
            ) ?? Self.defaultWorkspaceSidebarWidth
            self.inspectorSidebarWidth = try container.decodeIfPresent(
                Double.self,
                forKey: .inspectorSidebarWidth
            ) ?? Self.defaultInspectorSidebarWidth
        }
    }

    /// The appearance of the app
    /// - **system**: uses the system appearance
    /// - **dark**: always uses dark appearance
    /// - **light**: always uses light appearance
    enum Appearances: String, Codable {
        case system
        case light
        case dark

        /// Applies the selected appearance
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
    enum Issues: String, Codable {
        case inline
        case minimized
    }

    /// The style for file extensions visibility
    ///  - **hideAll**: File extensions are hidden
    ///  - **showAll** File extensions are visible
    ///  - **showOnly** Specific file extensions are visible
    ///  - **hideOnly** Specific file extensions are hidden
    enum FileExtensionsVisibility: Codable, Hashable {
        case hideAll
        case showAll
        case showOnly
        case hideOnly
    }

    /// The collection of file extensions used by
    /// ``FileExtensionsVisibility/showOnly`` or  ``FileExtensionsVisibility/hideOnly`` preference
    struct FileExtensions: Codable, Hashable {
        public var extensions: [String]

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

        public static var `default` = FileExtensions(extensions: [
            "c", "cc", "cpp", "h", "hpp", "m", "mm", "gif",
            "icns", "jpeg", "jpg", "png", "tiff", "swift"
        ])
    }
    /// The style for file icons
    /// - **color**: File icons appear in their default colors
    /// - **monochrome**: File icons appear monochromatic
    enum FileIconStyle: String, Codable {
        case color
        case monochrome
    }

    /// The style for tab bar
    /// - **native**: Native-styled tab bar (like Finder)
    /// - **xcode**: Xcode-liked tab bar
    enum TabBarStyle: String, Codable {
        case native
        case xcode
    }

    /// The style for the sidebar's mode selection
    /// - **xcode**: Xcode-like mode selection
    /// - **vscode**: VSCode-like mode seliction
    enum SidebarStyle: String, Codable {
        case xcode
        case vscode
    }

    /// If the menu item should be shwon
    /// - **shown**: The menu bar item is shown
    /// - **hidden**: The menu bar item is hidden
    enum MenuBarShow: String, Codable {
        case shown
        case hidden
    }

    /// The reopen behavior of the app
    /// - **welcome**: On restart the app will show the welcome screen
    /// - **openPanel**: On restart the app will show an open panel
    /// - **newDocument**: On restart a new empty document will be created
    enum ReopenBehavior: String, Codable {
        case welcome
        case openPanel
        case newDocument
    }

    enum ProjectNavigatorSize: String, Codable {
        case small
        case medium
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
    enum NavigatorDetail: Int, Codable, CaseIterable {
        case upTo1 = 1
        case upTo2 = 2
        case upTo3 = 3
        case upTo4 = 4
        case upTo5 = 5
        case upTo10 = 10
        case upTo30 = 30

        var label: String {
            switch self {
            case .upTo1:
                return "One Line"
            default:
                return "Up to \(self.rawValue) lines"
            }
        }
    }
}

func aeCommandLine() {
    do {
        let url = Bundle.main.url(forResource: "ae", withExtension: nil, subdirectory: "Resources")
        let destination = "/usr/local/bin/ae"

        if FileManager.default.fileExists(atPath: destination) {
            try FileManager.default.removeItem(atPath: destination)
        }

        guard let shellUrl = url?.path else {
            Log.error("Failed to get URL to shell command")
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
        Log.error("\(error)")
    }
}

func fallbackShellInstallation(commandPath: String, destinationPath: String) {
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
        Log.error("\(error)")
    }
}
