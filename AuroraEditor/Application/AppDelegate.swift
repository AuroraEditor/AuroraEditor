//
//  AppDelegate.swift
//  Aurora Editor
//
//  Created by Pavel Kasila on 12/03/2022.
//  Copyright © 2023 Aurora Company. All rights reserved.
//

import SwiftUI
import Combine

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

@NSApplicationMain
final class AppDelegate: NSObject, NSApplicationDelegate, ObservableObject {
    func applicationWillFinishLaunching(_ notification: Notification) {
    }

    var statusItem: NSStatusItem?

    private var updateModel: UpdateObservedModel = .shared

    var cancellable = Set<AnyCancellable>()

    func applicationDidFinishLaunching(_ notification: Notification) {
        // Register storage locations if needed.
        LocalStorage().registerStorage()

        // Initialize AuroraCrashlytics delegate.
        AuroraCrashlytics.add(delegate: self)

        // Apply application appearance preferences.
        AppPreferencesModel.shared.preferences.general.appAppearance.applyAppearance()

        // Check for and open files associated with the application.
        checkForFilesToOpen()

        DispatchQueue.main.async {
            if let projects = UserDefaults.standard.array(forKey: AppDelegate.recoverWorkspacesKey) as? [String],
               !projects.isEmpty {
                projects.forEach { path in
                    let url = URL(fileURLWithPath: path)
                    // Reopen documents associated with the projects.
                    AuroraEditorDocumentController.shared.reopenDocument(
                        for: url,
                        withContentsOf: url,
                        display: true) { document, _, _ in
                            Log.info("Opened project: \(url.absoluteString)")
                            document?.windowControllers.first?.synchronizeWindowTitleWithDocumentName()
                    }
                }
            } else {
                // If no projects to recover, handle other open requests.
                self.handleOpen()
            }

            // Check for command-line arguments to open specific files.
            for index in 0..<CommandLine.arguments.count {
                if CommandLine.arguments[index] == "--open" && (index + 1) < CommandLine.arguments.count {
                    let path = CommandLine.arguments[index + 1]
                    let url = URL(fileURLWithPath: path)

                    AuroraEditorDocumentController.shared.reopenDocument(
                        for: url,
                        withContentsOf: url,
                        display: true) { document, _, _ in
                            Log.info("Opened file via command line: \(url.absoluteString)")
                            document?.windowControllers.first?.synchronizeWindowTitleWithDocumentName()
                    }
                    Log.info("No need to open the Welcome Screen (command line)")
                }
            }
        }

        if NSApp.activationPolicy() == .regular {
            if statusItem == nil {
                // Create a status item if the menu item show mode is set to "shown."
                if AppPreferencesModel.shared.preferences.general.menuItemShowMode == .shown {
                    self.statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
                    guard let statusItem = statusItem else {
                        return
                    }
                    setup(statusItem: statusItem)
                }
            }
        }

        // Check for updates
        updateModel.checkForUpdates()
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
        // Extract the paths of open projects (WorkspaceDocuments).
        let projects = AuroraEditorDocumentController.shared.documents.compactMap { doc in
            (doc as? WorkspaceDocument)?.fileURL?.path
        }

        // Save the paths of open projects to UserDefaults.
        UserDefaults.standard.set(projects, forKey: AppDelegate.recoverWorkspacesKey)

        // Close and remove all open documents.
        AuroraEditorDocumentController.shared.documents.forEach { doc in
            doc.close()
            AuroraEditorDocumentController.shared.removeDocument(doc)
        }

        // Check if a crash report date is stored in UserDefaults and display a crash report window if available.
        if let crashDate = UserDefaults.standard.string(forKey: "crash") {
            CrashReportView(errorDetails: crashDate).showWindow()
        }

        return .terminateNow
    }

    // MARK: - Open windows

    @IBAction func openPreferences(_ sender: Any) {
        if !AppDelegate.tryFocusWindow(of: PreferencesView.self) {
            PreferencesView().showWindow()
        }
    }

    @IBAction func openWelcome(_ sender: Any) {
        if !AppDelegate.tryFocusWindow(of: WelcomeWindowView.self) {
            WelcomeWindowView.openWelcomeWindow()
        }
    }

    @IBAction public func openAbout(_ sender: Any) {
        if !AppDelegate.tryFocusWindow(of: AboutView.self) {
            AboutView().showWindow()
        }
    }

    @IBAction func openFeedback(_ sender: Any) {
        if !AppDelegate.tryFocusWindow(of: FeedbackView.self) {
            FeedbackView().showWindow()
        }
    }

    /// Open about window
    static func openAboutWindow() {
        if !tryFocusWindow(of: AboutView.self) {
            AboutView().showWindow()
        }
    }

    /// Attempt to focus a window containing a specific type of NSHostingView.
    ///
    /// - Parameters:
    ///   - type: The type of the NSHostingView to search for in windows.
    /// - Returns: `true` if a window containing the specified view type is found and brought
    ///             to the front; `false` otherwise.
    static func tryFocusWindow<T: View>(of type: T.Type) -> Bool {
        // Use the first(where:) method to find the first window with the desired contentView.
        if let window = NSApp.windows.first(where: { $0.contentView is NSHostingView<T> }) {
            // If a matching window is found, bring it to the front.
            window.makeKeyAndOrderFront(self)
            return true
        }
        // If no matching window is found, return false.
        return false
    }

    // MARK: - Open With AuroraEditor (Extension) functions
    private func checkForFilesToOpen() {
        // Access UserDefaults with a specific suite name.
        guard let defaults = UserDefaults(suiteName: "com.auroraeditor.shared") else {
            Log.error("Failed to get/init shared defaults")
            return
        }

        // Register a default value for the "enableOpenInAE" key if not already registered.
        if !defaults.bool(forKey: "enableOpenInAE") {
            defaults.set(true, forKey: "enableOpenInAE")
        }

        // Check if there are files to open stored in UserDefaults.
        if let filesToOpen = defaults.string(forKey: "openInAEFiles") {
            // Split the semicolon-separated file paths into an array.
            let files = filesToOpen.split(separator: ";")

            // Process each file URL in parallel using DispatchQueue.concurrentPerform.
            DispatchQueue.concurrentPerform(iterations: files.count) { item in
                let filePath = files[item]
                let fileURL = URL(fileURLWithPath: String(filePath))

                // Attempt to reopen the document associated with the file URL.
                AuroraEditorDocumentController.shared.reopenDocument(
                    for: fileURL,
                    withContentsOf: fileURL,
                    display: true) { document, _, _ in
                        // Log information about the opened file.
                        Log.info("checkForFilesToOpen(): Opened \(fileURL.absoluteString)")

                        // Synchronize the window title with the document name.
                        document?.windowControllers.first?.synchronizeWindowTitleWithDocumentName()
                }
            }

            // Remove the "openInAEFiles" key from UserDefaults after processing.
            defaults.removeObject(forKey: "openInAEFiles")
        }
    }
}

extension AppDelegate {
    static let recoverWorkspacesKey = "recover.workspaces"
}

extension AppDelegate: AuroraCrashlyticsDelegate {
    func auroraCrashlyticsDidCatchCrash(with model: CrashModel) {
        UserDefaults.standard.set(model.reason + "(\(Date()))", forKey: "crash")
    }
}
