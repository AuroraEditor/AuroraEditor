//
//  WorkspaceDocument.swift
//  Aurora Editor
//
//  Created by Pavel Kasila on 17.03.22.
//  Copyright © 2023 Aurora Company. All rights reserved.
//

import Foundation
import AppKit
import SwiftUI
@preconcurrency import Combine
import AEExtensionKit
import OSLog

/// A class that represents a workspace document.
@objc(WorkspaceDocument)
class WorkspaceDocument: NSDocument, ObservableObject, NSToolbarDelegate {
    /// The FileSystemClient instance that manages the project's file system
    var fileSystemClient: FileSystemClient?

    /// The extension navigator data
    var extensionNavigatorData: ExtensionNavigatorData? = ExtensionNavigatorData()

    private var workspaceUtils: WorkspaceUtils?

    /// The selection state
    @Published
    var selectionState: WorkspaceSelectionState = .init()

    /// The data storage
    @Published
    var data = AuroraDataStorage()

    /// The broadcaster
    @Published
    var broadcaster = AuroraCommandBroadcaster()

    /// The notification list
    @Published
    var notificationList: [String] = []

    /// The warning list
    @Published
    var warningList: [String] = []

    /// The error list
    @Published
    var errorList: [String] = []

    /// The file items
    @Published
    var fileItems: [FileSystemClient.FileItem] = []

    /// The editor configuration
    var editorConfig: AuroraEditorConfig = .init(fromPath: "/")

    /// The current filter
    public var filter: String = "" {
        didSet { fileSystemClient?.onRefresh() }
    }

    /// The status bar model
    var statusBarModel: StatusBarModel?

    /// The search state
    var searchState: SearchState?

    /// The quick open state
    var quickOpenState: QuickOpenState?

    /// The command palette state
    var commandPaletteState: CommandPaletteState?

    /// The new file model
    var newFileModel: NewFileModel = .init()

    /// The workspace notification model
    var listenerModel: WorkspaceNotificationModel = .init()

    /// The cancellables
    private var cancellables = Set<AnyCancellable>()

    /// Deinitializer
    deinit {
        cancellables.forEach { $0.cancel() }
        NotificationCenter.default.removeObserver(self)
    }

    /// debugDescription
    override var debugDescription: String {
        let path = fileSystemClient?.folderURL?.path ?? "unknown"
        return "WorkspaceDocument with path \(path)"
    }

    // MARK: NSDocument

    /// The ignored files and directories
    private let ignoredFilesAndDirectory = [
        ".DS_Store"
    ]

    /// Autosaves in place
    override class var autosavesInPlace: Bool {
        false
    }

    /// Is document edited
    override var isDocumentEdited: Bool {
        false
    }

    /// The window controller
    var windowController: AuroraEditorWindowController?

    /// Document URL
    ///
    /// This is a safe-wrapper for `fileURL`
    var documentURL: URL {
        guard let url = self.fileURL else {
            fatalError("The WorkspaceDocument doesn't have a file URL")
        }

        return url
    }

    /// Workspace Folder URL
    var folderURL: URL {
        guard let workspaceFolder = self.fileSystemClient?.folderURL else {
            return emptyURL
        }

        return workspaceFolder
    }

    /// Logger
    let logger = Logger(subsystem: "com.auroraeditor", category: "Workspace Document")

    /// Make window controllers
    override func makeWindowControllers() {
        let window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 800, height: 600),
            styleMask: [.titled, .closable, .miniaturizable, .resizable, .fullSizeContentView],
            backing: .buffered, defer: false
        )
        window.minSize = .init(width: 1000, height: 600)
        let windowController = AuroraEditorWindowController(
            window: window,
            workspace: self
        )
        self.addWindowController(windowController)
        self.windowController = windowController
        DispatchQueue.main.async {
            window.center()
        }
    }

    // MARK: Set Up Workspace
    /// Init workspace state
    /// 
    /// - Parameter url: The URL of the workspace.
    private func initWorkspaceState(_ url: URL) throws {
        self.fileSystemClient = .init(
            fileManager: .default,
            folderURL: url,
            ignoredFilesAndFolders: ignoredFilesAndDirectory,
            model: .init(workspaceURL: url)
        )
        self.searchState = .init(self)
        self.quickOpenState = .init(fileURL: url)
        self.statusBarModel = .init(workspaceURL: url)
        self.commandPaletteState = .init(possibleCommands: [])
        self.newFileModel = .init(workspace: self)
        self.workspaceUtils = WorkspaceUtils(workspace: self)
        setupCommands()

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(convertTemporaryTab),
            name: .didBeginEditing,
            object: nil
        )

        if #available(macOS 13.0, *) {
            editorConfig = AuroraEditorConfig(fromPath: url.path(percentEncoded: false))
        } else {
            editorConfig = AuroraEditorConfig(fromPath: url.path)
        }

        self.logger.info("Created document \(self)")

        workspaceUtils?.setupVersionControlMonitor()
    }

    /// Retrieves selection state from UserDefaults using SHA256 hash of project  path as key
    /// - Throws: `DecodingError.dataCorrupted` error if retrived data from UserDefaults is not decodable
    /// - Returns: retrived state from UserDefaults or default state if not found
    private func readSelectionState() throws -> WorkspaceSelectionState {
        guard let path = fileURL?.path,
              let data = UserDefaults.standard.value(forKey: path.sha256()) as? Data  else { return selectionState }
        let state = try PropertyListDecoder().decode(WorkspaceSelectionState.self, from: data)
        return state
    }

    /// Read from URL
    /// 
    /// - Parameter url: The URL.
    /// - Parameter typeName: The type name.
    override func read(from url: URL, ofType typeName: String) throws {
        try initWorkspaceState(url)

        // Initialize Workspace
        do {
            selectionState = try readSelectionState()
            selectionState.workspace = self
        } catch {
            self.logger.warning("Couldn't retrieve selection state from user defaults")
        }

        fileSystemClient?
            .getFiles
            .sink { [weak self] files in
                guard let self = self else { return }

                guard !self.fileItems.isEmpty else {
                    self.fileItems = files
                    return
                }

                // Instead of rebuilding the array we want to
                // calculate the difference between the last iteration
                // and now. If the index of the file exists in the array
                // it means we need to remove the element, otherwise we need to append
                // it.
                let diff = files.difference(from: self.fileItems)
                diff.forEach { newFile in
                    if let index = self.fileItems.firstIndex(of: newFile) {
                        self.fileItems.remove(at: index)
                    } else {
                        self.fileItems.append(newFile)
                    }
                }
            }
            .store(in: &cancellables)

        self.logger.info("Made document from read: \(self)")
    }

    /// Write to URL
    /// 
    /// - Parameter url: The URL.
    /// - Parameter typeName: The type name.
    override func write(to url: URL, ofType typeName: String) throws {}

    // MARK: Close Workspace

    /// Saves selection state to UserDefaults using SHA256 hash of project  path as key
    /// - Throws: `EncodingError.invalidValue` error if sellection state is not encodable
    private func saveSelectionState() throws {
        guard let path = fileURL?.path else { return }
        let hash = path.sha256()
        let data = try PropertyListEncoder().encode(selectionState)
        UserDefaults.standard.set(data, forKey: hash)
    }

    /// Close
    override func close() {
        do {
            try saveSelectionState()
        } catch {
            self.logger.fault("Couldn't save selection state from user defaults")
        }

        selectionState.selectedId = nil
        selectionState.openFileItems.forEach { item in
            do {
                try selectionState.openedCodeFiles[item]?.write(to: item.url, ofType: "public.source-code")
                selectionState.openedCodeFiles[item]?.close()
            } catch {}
        }
        selectionState.openedCodeFiles.removeAll()

        // deinit classes
        cancellables.forEach { $0.cancel() }
        self.fileSystemClient?.cleanUp()
        self.fileSystemClient?.model = nil
        self.fileSystemClient = nil
        self.searchState = nil
        self.quickOpenState = nil
        self.commandPaletteState = nil
        self.statusBarModel = nil
        for windowController in self.windowControllers {
            self.removeWindowController(windowController)
        }
        self.extensionNavigatorData = nil

        super.close()
        self.logger.info("Closed document \(self)")

        workspaceUtils?.cleanupVersionControlMonitor()
    }
}
