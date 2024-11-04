//
//  AppDelegate.swift
//  Aurora Editor
//
//  Created by Pavel Kasila on 12/03/2022.
//  Copyright © 2023 Aurora Company. All rights reserved.
//

import SwiftUI
import Combine
import AuroraEditorLanguage
import OSLog

/// AuroraEditorApplication
///
/// The main application class for Aurora Editor.
///
/// This class is responsible for initializing the application and setting the application delegate.
@MainActor
final class AuroraEditorApplication: NSApplication {
    /// The strong reference to the application delegate.
    let strongDelegate = AppDelegate()

    /// Initialize the application with the strong delegate.
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
/// AppDelegate
///
/// The main application delegate for Aurora Editor.
///
/// This class is responsible for handling application lifecycle events, such as application
/// launch, termination, and reopening. It also manages the status item and the main menu.
///
@MainActor
final class AppDelegate: NSObject, NSApplicationDelegate, ObservableObject {
    func applicationWillFinishLaunching(_ notification: Notification) {
    }

    /// The status item for the application.
    var statusItem: NSStatusItem?

    /// Model for handling application updates.
    private var updateModel: UpdateObservedModel = .shared

    /// Model for handling language registry.
    private var languageRegistery: LanguageRegistry = .shared

    /// Set of cancellable objects for Combine subscriptions.
    var cancellable = Set<AnyCancellable>()

    /// Logger
    let logger = Logger(subsystem: "com.auroraeditor", category: "App Delegate")

    var isRunningTests: Bool {
        return ProcessInfo.processInfo.environment["XCTestConfigurationFilePath"] != nil
    }

    /// Initialize the application delegate.
    /// - Parameter notification: The notification object.
    func applicationDidFinishLaunching(_ notification: Notification) {
        // swiftlint:disable:previous function_body_length

        logger
            .debug("\(self.isRunningTests ? "We are running tests." : "We are not running tests.")")

        // Register storage locations if needed.
        LocalStorage().registerStorage()

        // Initialize AuroraCrashlytics delegate.
        AuroraCrashlytics.add(delegate: self)

        // Apply application appearance preferences.
        AppPreferencesModel.shared.preferences.general.appAppearance.applyAppearance()

        // We do NOT want permission dialogues while testing.
        if !isRunningTests {
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
                                self.logger.info("Opened project: \(url.absoluteString)")
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
                                self.logger.info("Opened file via command line: \(url.absoluteString)")
                                document?.windowControllers.first?.synchronizeWindowTitleWithDocumentName()
                        }

                        self.logger.info("No need to open the Welcome Screen (command line)")
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

        // Handle language registry
        handleLanguageRegisteredNotification()

        // Initialize AE Spotlight
        CoreSpotlight().update()
    }

    /// Code to run when the application is about to terminate.
    ///
    /// - Parameter aNotification: The notification object.
    func applicationWillTerminate(_ aNotification: Notification) {
    }

    /// Define if the application supports secure restorable state.
    ///
    /// - Parameter notification: The notification object.
    func applicationSupportsSecureRestorableState(_ app: NSApplication) -> Bool {
        !isRunningTests
    }

    /// Code to run when the application is about reopen.
    ///
    /// - Parameter notification: The notification object.
    /// - Parameter hasVisibleWindows: A boolean value indicating whether the application has visible windows.
    func applicationShouldHandleReopen(_ sender: NSApplication, hasVisibleWindows flag: Bool) -> Bool {
        if flag {
            return false
        }

        handleOpen()

        return false
    }

    /// Code to run when the application is about to open an untitled file.
    ///
    /// - Parameter sender: The sender of the action.
    func applicationShouldOpenUntitledFile(_ sender: NSApplication) -> Bool {
        false
    }

    /// Code to run when the application is about to open a file.
    ///
    /// - Parameter funct: The caller function name.
    @MainActor
    func handleOpen(funct: String = #function) {
        if isRunningTests {
            // Do not (reopen) if testing
            return
        }

        self.logger.info("handleOpen() called from \(funct)")
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

    /// Code to run when the application is about to terminate.
    ///
    /// - Parameter sender: The sender of the action.
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

        // Terminate the application.
        return .terminateNow
    }

    // MARK: - Open windows
    /// Open the preferences window.
    ///
    /// - Parameter sender: The sender of the action.
    @IBAction func openPreferences(_ sender: Any) {
        if !AppDelegate.tryFocusWindow(of: PreferencesView.self) {
            PreferencesView().showWindow()
        }
    }

    // Open the welcome window.
    ///
    /// - Parameter sender: The sender of the action.
    @IBAction func openWelcome(_ sender: Any) {
        if !AppDelegate.tryFocusWindow(of: WelcomeWindowView.self) {
            WelcomeWindowView.openWelcomeWindow()
        }
    }

    /// Open the about window.
    ///
    /// - Parameter sender: The sender of the action.
    @IBAction public func openAbout(_ sender: Any) {
        if !AppDelegate.tryFocusWindow(of: AboutView.self) {
            AboutView().showWindow()
        }
    }

    /// Open the feedback window.
    ///
    /// - Parameter sender: The sender of the action.
    @IBAction func openFeedback(_ sender: Any) {
        if !AppDelegate.tryFocusWindow(of: FeedbackView.self) {
            FeedbackView().showWindow()
        }
    }

    /// Open about window
    @MainActor
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
    @MainActor
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
    @MainActor
    private func checkForFilesToOpen() {
        // Access UserDefaults with a specific suite name.
        guard let defaults = UserDefaults(suiteName: "com.auroraeditor.shared") else {
            self.logger.fault("Failed to get/init shared defaults")
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
                        self.logger.info("checkForFilesToOpen(): Opened \(fileURL.absoluteString)")

                        // Synchronize the window title with the document name.
                        document?.windowControllers.first?.synchronizeWindowTitleWithDocumentName()
                }
            }

            // Remove the "openInAEFiles" key from UserDefaults after processing.
            defaults.removeObject(forKey: "openInAEFiles")
        }
    }

    private func handleLanguageRegisteredNotification() {
        BashLanguageHandler().registerLanguage()
        CLanguageHandler().registerLanguage()
        CPPLanguageHandler().registerLanguage()
        CSharpLanguageHandler().registerLanguage()
        CSSLanguageHandler().registerLanguage()
        GoLanguageHandler().registerLanguage()
        JavaLanguageHandler().registerLanguage()
        JavascriptLanguageHandler().registerLanguage()
        OcamlLanguageHandler().registerLanguage()
        PhpLanguageHandler().registerLanguage()
        RubyLanguageHandler().registerLanguage()
        PlainTextLanguageHandler().registerLanguage()
    }
}

extension AppDelegate {
    static let recoverWorkspacesKey = "recover.workspaces"
}

extension AppDelegate: AuroraCrashlyticsDelegate {
    nonisolated func auroraCrashlyticsDidCatchCrash(with model: CrashModel) {
        UserDefaults.standard.set(model.reason + "(\(Date()))", forKey: "crash")
    }
}
