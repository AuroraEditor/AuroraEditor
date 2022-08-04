//
//  AuroraEditororAppDelegate.swift
//  AuroraEditor
//
//  Created by Pavel Kasila on 12.03.22.
//

import SwiftUI
import Preferences

final class AuroraEditorApplication: NSApplication {
    let strongDelegate = AppDelegate()

    override init() {
        super.init()
        self.delegate = strongDelegate
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}

/**
 2022-07-26 21:07:49.347758+0200 AuroraEditor[48132:1157389]
 -[NSTaggedPointerString objectForKey:]: unrecognized selector sent to instance 0x8000000000000000
 2022-07-26 21:07:49.386108+0200 AuroraEditor[48132:1157389]
 *** Terminating app due to uncaught exception 'NSInvalidArgumentException',
 reason: '-[NSTaggedPointerString objectForKey:]: unrecognized selector sent to instance 0x8000000000000000'
 */
@NSApplicationMain
final class AppDelegate: NSObject, NSApplicationDelegate, ObservableObject {
    func applicationWillFinishLaunching(_ notification: Notification) {
        _ = AuroraEditorDocumentController.shared
    }

    func applicationDidFinishLaunching(_ notification: Notification) {

        AuroraCrashlytics.add(delegate: self)

        AppPreferencesModel.shared.preferences.general.appAppearance.applyAppearance()
        checkForFilesToOpen()

        DispatchQueue.main.async {
            var needToHandleOpen = true

            if NSApp.windows.isEmpty {
                if let projects = UserDefaults.standard.array(forKey: AppDelegate.recoverWorkspacesKey) as? [String],
                   !projects.isEmpty {
                    projects.forEach { path in
                        print(#function, "Reopening \(path)")
                        let url = URL(fileURLWithPath: path)
                        AuroraEditorDocumentController.shared.reopenDocument(
                            for: url,
                            withContentsOf: url,
                            display: true) { document, _, _ in
                                print("applicationDidFinishLaunching(): projects: Opened \(url.absoluteString)")
                                document?.windowControllers.first?.synchronizeWindowTitleWithDocumentName()
                        }
                    }

                    print("No need to open Welcome Screen (projects)")
                    needToHandleOpen = false
                } else {
                    print("No open project.")
                }
            }

            for index in 0..<CommandLine.arguments.count {
                if CommandLine.arguments[index] == "--open" && (index + 1) < CommandLine.arguments.count {
                    let path = CommandLine.arguments[index+1]
                    let url = URL(fileURLWithPath: path)

                    AuroraEditorDocumentController.shared.reopenDocument(
                        for: url,
                        withContentsOf: url,
                        display: true) { document, _, _ in
                            print("applicationDidFinishLaunching(): commandline: Opened \(url.absoluteString)")
                            document?.windowControllers.first?.synchronizeWindowTitleWithDocumentName()
                    }

                    print("No need to open Welcome Screen (commandline)")
                    needToHandleOpen = false
                }
            }

            if needToHandleOpen {
                print("need to open Welcome Screen")
                self.handleOpen()
            }
        }

        do {
            try ExtensionsManager.shared?.preload()
        } catch let error {
            print(error)
        }
    }

    func applicationWillTerminate(_ aNotification: Notification) {
    }

    func applicationSupportsSecureRestorableState(_ app: NSApplication) -> Bool {
        true
    }

    func applicationShouldHandleReopen(_ sender: NSApplication, hasVisibleWindows flag: Bool) -> Bool {
        if flag {
            return false
        }

        handleOpen()

        return false
    }

    func applicationShouldOpenUntitledFile(_ sender: NSApplication) -> Bool {
        false
    }

    func handleOpen(funct: String = #function) {
        Log.info("handleOpen() called from \(funct)")
        let behavior = AppPreferencesModel.shared.preferences.general.reopenBehavior

        switch behavior {
        case .welcome:
            openWelcome(self)
        case .openPanel:
            AuroraEditorDocumentController.shared.openDocument(self)
        case .newDocument:
            AuroraEditorDocumentController.shared.newDocument(self)
        }
    }

    func applicationShouldTerminate(_ sender: NSApplication) -> NSApplication.TerminateReply {
        let projects: [String] = AuroraEditorDocumentController.shared.documents
            .map { doc in
                (doc as? WorkspaceDocument)?.fileURL?.path
            }
            .filter { $0 != nil }
            .map { $0! }

        UserDefaults.standard.set(projects, forKey: AppDelegate.recoverWorkspacesKey)

        AuroraEditorDocumentController.shared.documents.forEach { doc in
            doc.close()
            AuroraEditorDocumentController.shared.removeDocument(doc)
        }

        if let date = UserDefaults.standard.string(forKey: "crash") {
            CrashReportView(errorDetails: date).showWindow()
        }

        return .terminateNow
    }

    // MARK: - Open windows

    @IBAction func openPreferences(_ sender: Any) {
        preferencesWindowController.show()
    }

    @IBAction func openWelcome(_ sender: Any) {
        if tryFocusWindow(of: WelcomeWindowView.self) { return }

        WelcomeWindowView.openWelcomeWindow()
    }

    @IBAction func openAbout(_ sender: Any) {
        if tryFocusWindow(of: AboutView.self) { return }

        AboutView().showWindow(width: 530, height: 220)
    }

    @IBAction func openFeedback(_ sender: Any) {
        if tryFocusWindow(of: FeedbackView.self) { return }

        FeedbackView().showWindow()
    }

    /// Tries to focus a window with specified view content type.
    /// - Parameter type: The type of viewContent which hosted in a window to be focused.
    /// - Returns: `true` if window exist and focused, oterwise - `false`
    private func tryFocusWindow<T: View>(of type: T.Type) -> Bool {
        guard let window = NSApp.windows.filter({ ($0.contentView as? NSHostingView<T>) != nil }).first
        else { return false }

        window.makeKeyAndOrderFront(self)
        return true
    }

    // MARK: - Open With AuroraEditor (Extension) functions
    private func checkForFilesToOpen() {
        guard let defaults = UserDefaults.init(
            suiteName: "com.auroraeditor.shared"
        ) else {
            Log.error("Failed to get/init shared defaults")
            return
        }

        // Register enableOpenInCE (enable Open In AuroraEditor
        defaults.register(defaults: ["enableOpenInAE": true])

        if let filesToOpen = defaults.string(forKey: "openInAEFiles") {
            let files = filesToOpen.split(separator: ";")

            for filePath in files {
                let fileURL = URL(fileURLWithPath: String(filePath))
                AuroraEditorDocumentController.shared.reopenDocument(
                    for: fileURL,
                    withContentsOf: fileURL,
                    display: true) { document, _, _ in
                        Log.info("checkForFilesToOpen(): Opened \(fileURL.absoluteString)")
                        document?.windowControllers.first?.synchronizeWindowTitleWithDocumentName()
                    }
            }

            defaults.removeObject(forKey: "openInAEFiles")
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.checkForFilesToOpen()
        }
    }

    // MARK: - Preferences
    private lazy var preferencesWindowController = PreferencesWindowController(
        panes: [
            Preferences.Pane(
                identifier: Preferences.PaneIdentifier("GeneralSettings"),
                title: "General",
                toolbarIcon: NSImage(systemSymbolName: "gearshape", accessibilityDescription: nil)!
            ) {
                GeneralPreferencesView()
            },
            Preferences.Pane(
                identifier: Preferences.PaneIdentifier("Accounts"),
                title: "Accounts",
                toolbarIcon: NSImage(systemSymbolName: "at", accessibilityDescription: nil)!
            ) {
                PreferenceAccountsView()
            },
            Preferences.Pane(
                identifier: Preferences.PaneIdentifier("Behaviors"),
                title: "Behaviors",
                toolbarIcon: NSImage(systemSymbolName: "flowchart", accessibilityDescription: nil)!
            ) {
                PreferencesPlaceholderView()
            },
            Preferences.Pane(
                identifier: Preferences.PaneIdentifier("Navigation"),
                title: "Navigation",
                toolbarIcon: NSImage(systemSymbolName: "arrow.triangle.turn.up.right.diamond",
                                     accessibilityDescription: nil)!
            ) {
                PreferencesPlaceholderView()
            },
            Preferences.Pane(
                identifier: Preferences.PaneIdentifier("Themes"),
                title: "Themes",
                toolbarIcon: NSImage(systemSymbolName: "paintbrush", accessibilityDescription: nil)!
            ) {
                ThemePreferencesView()
            },
            Preferences.Pane(
                identifier: Preferences.PaneIdentifier("TextEditing"),
                title: "Text Editing",
                toolbarIcon: NSImage(systemSymbolName: "square.and.pencil", accessibilityDescription: nil)!
            ) {
                TextEditingPreferencesView()
            },
            Preferences.Pane(
                identifier: Preferences.PaneIdentifier("Terminal"),
                title: "Terminal",
                toolbarIcon: NSImage(systemSymbolName: "terminal", accessibilityDescription: nil)!
            ) {
                TerminalPreferencesView()
            },
            Preferences.Pane(
                identifier: Preferences.PaneIdentifier("KeyBindings"),
                title: "Key Bindings",
                toolbarIcon: NSImage(systemSymbolName: "keyboard", accessibilityDescription: nil)!
            ) {
                PreferencesPlaceholderView()
            },
            Preferences.Pane(
                identifier: Preferences.PaneIdentifier("SourceControl"),
                title: "Source Control",
                toolbarIcon: NSImage.vault
            ) {
                PreferenceSourceControlView()
            },
            Preferences.Pane(
                identifier: Preferences.PaneIdentifier("Components"),
                title: "Components",
                toolbarIcon: NSImage(systemSymbolName: "puzzlepiece", accessibilityDescription: nil)!
            ) {
                PreferencesPlaceholderView()
            },
            Preferences.Pane(
                identifier: Preferences.PaneIdentifier("Locations"),
                title: "Locations",
                toolbarIcon: NSImage(systemSymbolName: "externaldrive", accessibilityDescription: nil)!
            ) {
                LocationsPreferencesView()
            },
            Preferences.Pane(
                identifier: Preferences.PaneIdentifier("Advanced"),
                title: "Advanced",
                toolbarIcon: NSImage(systemSymbolName: "gearshape.2", accessibilityDescription: nil)!
            ) {
                PreferencesPlaceholderView()
            }
        ],
        animated: false
    )
}

extension AppDelegate {
    static let recoverWorkspacesKey = "recover.workspaces"
}

extension AppDelegate: AuroraCrashlyticsDelegate {
    func auroraCrashlyticsDidCatchCrash(with model: CrashModel) {
        UserDefaults.standard.set(model.reason + "(\(Date()))", forKey: "crash")
    }
}
