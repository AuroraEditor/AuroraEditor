//
//  WorkspaceDocument.swift
//  AuroraEditor
//
//  Created by Pavel Kasila on 17.03.22.
//

import Foundation
import AppKit
import SwiftUI
import Combine
import AEExtensionKit

@objc(WorkspaceDocument)
class WorkspaceDocument: NSDocument, ObservableObject, NSToolbarDelegate {
    /// The FileSystemClient instance that manages the project's file system
    var fileSystemClient: FileSystemClient?

    var extensionNavigatorData: ExtensionNavigatorData? = ExtensionNavigatorData()

    @Published
    var sortFoldersOnTop: Bool = true
    @Published
    var showStashChangesSheet: Bool = false
    @Published
    var showRenameBranchSheet: Bool = false
    @Published
    var showAddRemoteView: Bool = false
    @Published
    var showBranchCreationSheet: Bool = false
    @Published
    var currentlySelectedBranch: String = ""
    @Published
    var branchRevision: String = ""
    @Published
    var branchRevisionDescription: String = ""

    @Published
    var selectionState: WorkspaceSelectionState = .init()

    @Published
    var fileItems: [FileSystemClient.FileItem] = []
    public var filter: String = "" {
        didSet { fileSystemClient?.onRefresh() }
    }

    var statusBarModel: StatusBarModel?
    var searchState: SearchState?
    var quickOpenState: QuickOpenState?
    var commandPaletteState: CommandPaletteState?
    var newFileModel: NewFileModel = .init()
    var listenerModel: WorkspaceNotificationModel = .init()
    private var cancellables = Set<AnyCancellable>()

    @Published
    var targets: [Target] = []

    deinit {
        cancellables.forEach { $0.cancel() }
        NotificationCenter.default.removeObserver(self)
    }

    override var debugDescription: String {
        let path = fileSystemClient?.folderURL?.path ?? "unknown"
        return "WorkspaceDocument with path \(path)"
    }

    // MARK: NSDocument

    private let ignoredFilesAndDirectory = [
        ".DS_Store"
    ]

    override class var autosavesInPlace: Bool {
        false
    }

    override var isDocumentEdited: Bool {
        false
    }

    var windowController: AuroraEditorWindowController?
    override func makeWindowControllers() {
        let window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 800, height: 600),
            styleMask: [.titled, .closable, .miniaturizable, .resizable, .fullSizeContentView],
            backing: .buffered, defer: false
        )
        window.center()
        window.minSize = .init(width: 1000, height: 600)
        let windowController = AuroraEditorWindowController(
            window: window,
            workspace: self
        )
        self.addWindowController(windowController)
        self.windowController = windowController
    }

    // MARK: Set Up Workspace

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
        setupCommands()

        NotificationCenter.default.addObserver(self,
                                               selector: #selector(convertTemporaryTab),
                                               name: NSNotification.Name("AE.didBeginEditing"),
                                               object: nil)
        Log.info("Created document \(self)")
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

    override func read(from url: URL, ofType typeName: String) throws {
        try initWorkspaceState(url)

        // Initialize Workspace
        do {
            selectionState = try readSelectionState()
            selectionState.workspace = self
        } catch {
            Log.warning("Couldn't retrieve selection state from user defaults")
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

        // initialize extensions
        do {
            try ExtensionsManager.shared?.load { extensionID in
                AuroraEditorAPI(extensionId: extensionID, workspace: self)
            }
        } catch let error {
            Log.error(error)
        }
        Log.info("Made document from read: \(self)")
    }

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

    override func close() {
        do {
            try saveSelectionState()
        } catch {
            Log.error("Couldn't save selection state from user defaults")
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
        Log.info("Closed document \(self)")
    }
}

// MARK: - Extensions
extension WorkspaceDocument {
    func target(didAdd target: Target) {
        self.targets.append(target)
    }
    func target(didRemove target: Target) {
        self.targets.removeAll { $0.id == target.id }
    }
    func targetDidClear() {
        self.targets.removeAll()
    }
}
