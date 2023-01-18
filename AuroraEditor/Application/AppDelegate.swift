//
//  AuroraEditororAppDelegate.swift
//  AuroraEditor
//
//  Created by Pavel Kasila on 12.03.22.
//

import SwiftUI
import Combine
import SwiftOniguruma
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

    var statusItem: NSStatusItem!

    private var updateModel: UpdateObservedModel = .shared

    var cancellable = Set<AnyCancellable>()

    func applicationDidFinishLaunching(_ notification: Notification) {
        AuroraCrashlytics.add(delegate: self)

        AppPreferencesModel.shared.preferences.general.appAppearance.applyAppearance()
        checkForFilesToOpen()

        DispatchQueue.main.async {
            if NSApp.windows.isEmpty {
                if let projects = UserDefaults.standard.array(forKey: AppDelegate.recoverWorkspacesKey) as? [String],
                   !projects.isEmpty {
                    projects.forEach { path in
                        Log.info(#function, "Reopening \(path)")
                        let url = URL(fileURLWithPath: path)
                        AuroraEditorDocumentController.shared.reopenDocument(
                            for: url,
                            withContentsOf: url,
                            display: true) { document, _, _ in
                                Log.info("applicationDidFinishLaunching(): projects: Opened \(url.absoluteString)")
                                document?.windowControllers.first?.synchronizeWindowTitleWithDocumentName()
                        }
                    }

                    Log.info("No need to open Welcome Screen (projects)")
                } else {
                    self.handleOpen()
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
                            Log.info("applicationDidFinishLaunching(): commandline: Opened \(url.absoluteString)")
                            document?.windowControllers.first?.synchronizeWindowTitleWithDocumentName()
                    }

                    Log.info("No need to open Welcome Screen (commandline)")
                }
            }
        }

        if AppPreferencesModel.shared.preferences.general.menuItemShowMode == .shown {
            self.statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
            setup(statusItem: statusItem)
        }

        // We disable checking for updates in debug builds as to not
        // annoy our fellow contributers
        #if !DEBUG
        updateModel.checkForUpdates()
        #endif

        Log.info("AURORA EDITOR is using SwiftOniguruma Version: \(SwiftOniguruma.version())!")
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
        if AppDelegate.tryFocusWindow(of: PreferencesView.self) { return }

        PreferencesView().showWindow()
    }

    @IBAction func openWelcome(_ sender: Any) {
        if AppDelegate.tryFocusWindow(of: WelcomeWindowView.self) { return }

        WelcomeWindowView.openWelcomeWindow()
    }

    @IBAction public func openAbout(_ sender: Any) {
        AppDelegate.openAboutWindow()
    }

    @IBAction func openFeedback(_ sender: Any) {
        if AppDelegate.tryFocusWindow(of: FeedbackView.self) { return }

        FeedbackView().showWindow()
    }

    /// Open about window
    static func openAboutWindow() {
        if tryFocusWindow(of: AboutView.self) { return }
        AboutView().showWindow(width: 530, height: 220)
    }

    /// Tries to focus a window with specified view content type.
    /// - Parameter type: The type of viewContent which hosted in a window to be focused.
    /// - Returns: `true` if window exist and focused, oterwise - `false`
    static func tryFocusWindow<T: View>(of type: T.Type) -> Bool {
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
}

extension AppDelegate {
    static let recoverWorkspacesKey = "recover.workspaces"
}

extension AppDelegate: AuroraCrashlyticsDelegate {
    func auroraCrashlyticsDidCatchCrash(with model: CrashModel) {
        UserDefaults.standard.set(model.reason + "(\(Date()))", forKey: "crash")
    }
}
