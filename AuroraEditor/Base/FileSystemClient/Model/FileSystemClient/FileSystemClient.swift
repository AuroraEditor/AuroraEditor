//
//  FileSystemClient.swift
//  Aurora Editor
//
//  Created by TAY KAI QUAN on 13/8/22.
//  Copyright © 2023 Aurora Company. All rights reserved.
//

import Combine
import Foundation

/// File System Client
public class FileSystemClient {

    // TODO: Turn into class variables
    /// callback function that is run when a change is detected in the file system.
    /// This usually contains a `reloadData` function.
    public var onRefresh: () -> Void = {}

    // Variables for the outside to interface with
    /// Get Files
    public var getFiles: AnyPublisher<[FileItem], Never> = {
        // Create a CurrentValueSubject with an initial empty array of FileItem
        let subject = CurrentValueSubject<[FileItem], Never>([])

        // Erase the subject's type to AnyPublisher
        return subject.eraseToAnyPublisher()
    }()
    /// Folder URL
    public var folderURL: URL?
    /// Version Control Model
    public var model: SourceControlModel?

    // These should be private but some functions need them public :(
    /// File Manager
    public var fileManager: FileManager
    /// Ignored files and folders
    public var ignoredFilesAndFolders: [String]
    /// Workspace item
    public let workspaceItem: FileItem
    /// Flattened file items
    public var flattenedFileItems: [String: FileItem]
    /// Subject
    private var subject = CurrentValueSubject<[FileItem], Never>([])

    /// A function that, given a file's path, returns a `FileItem` if it exists
    /// within the scope of the `FileSystemClient`.
    /// - Parameter id: The file's full path
    /// - Returns: The file item corresponding to the file
    public func getFileItem(_ id: String) throws -> FileItem {
        if let item = flattenedFileItems[id] {
            return item
        }

        throw FileSystemClientError.fileNotExist
    }

    /// Usually run when the owner of the `FileSystemClient` doesn't need it anymore.
    /// This de-inits most functions in the `FileSystemClient`, so that in case it isn't de-init'd it does not use up
    /// significant amounts of RAM.
    /// Cleans up directory monitoring and workspace items.
    public func cleanUp() {
        // Stop listening to directories and clear watchers first
        stopListeningToDirectory()

        // Clear workspace items
        workspaceItem.children = []
        flattenedFileItems = [workspaceItem.id: workspaceItem]

        Log.info("Cleaned up watchers and file items")
    }

    // MARK: Watchers
    private var isRunning: Bool = false
    private var anotherInstanceRan: Int = 0

    // run by dispatchsource watchers. Multiple instances may be concurrent,
    // so we need to be careful to avoid EXC_BAD_ACCESS errors.
    /// This is a function run by `DispatchSource` file watchers. Due to the nature of watchers, multiple
    /// instances may be running concurrently, so the function prevents more than one instance of it from
    /// running the main code body.
    /// - Parameter sourceFileItem: The `FileItem` corresponding to the file that triggered the `DispatchSource`
    func reloadFromWatcher(sourceFileItem: FileItem) {
        guard !isRunning else {
            anotherInstanceRan += 1
            return // Another instance is already running
        }

        isRunning = true
        defer {
            isRunning = false
            anotherInstanceRan = 0
        }

        // Reload files
        _ = try? rebuildFiles(fromItem: sourceFileItem)

        // Reload Git changes and update gitStatus
        reloadGitChanges()

        // Send updated children
        subject.send(workspaceItem.children ?? [])

        // Reload data in outline view controller through the main thread
        DispatchQueue.main.async {
            self.onRefresh()
        }

        // Handle cases where another instance attempted to run while this one was running
        while anotherInstanceRan > 0 {
            let somethingChanged = try? rebuildFiles(fromItem: workspaceItem)
            anotherInstanceRan = !(somethingChanged ?? false) ? 0 : anotherInstanceRan - 1
        }
    }

    func reloadGitChanges() {
        model?.reloadChangedFiles()
        for changedFile in (model?.changed ?? []) {
            flattenedFileItems[changedFile.id]?.gitStatus = changedFile.gitStatus
        }
    }

    /// A function to kill the watcher of a specific directory, or all directories.
    /// - Parameter directory: The directory to stop watching, or nil to stop watching everything.
    func stopListeningToDirectory(directory: URL? = nil) {
        if let directory = directory {
            if let item = flattenedFileItems[directory.relativePath] {
                item.watcher?.cancel()
                item.watcher = nil
            }
        } else {
            for item in flattenedFileItems.values {
                item.watcher?.cancel()
                item.watcher = nil
            }
        }
    }

    // MARK: Init
    /// Init
    /// - Parameters:
    ///   - fileManager: file manager
    ///   - folderURL: Folder URL
    ///   - ignoredFilesAndFolders: ignored files and folders
    ///   - model: Version control model
    public init(fileManager: FileManager,
                folderURL: URL,
                ignoredFilesAndFolders: [String],
                model: SourceControlModel?) {
        // Initialize essential properties
        self.fileManager = fileManager
        self.folderURL = folderURL
        self.ignoredFilesAndFolders = ignoredFilesAndFolders
        self.model = model

        // Initialize the workspace fileItem
        workspaceItem = FileItem(url: folderURL, children: [])
        flattenedFileItems = [workspaceItem.id: workspaceItem]

        // Configure the getFiles publisher
        getFiles = subject
            .handleEvents(receiveCancel: {
                self.cancelWatchers()
            })
            .receive(on: RunLoop.main)
            .eraseToAnyPublisher()

        // Set the watcher code and initial file monitoring
        configureWorkspaceItem()

        // Set the file system client reference
        workspaceItem.fileSystemClient = self
    }

    // Configure the workspace item's watcher and initial monitoring
    private func configureWorkspaceItem() {
        workspaceItem.watcherCode = { sourceFileItem in
            self.reloadFromWatcher(sourceFileItem: sourceFileItem)
        }
        reloadFromWatcher(sourceFileItem: workspaceItem)
    }

    // Cancel watchers for all file items
    private func cancelWatchers() {
        for item in flattenedFileItems.values {
            item.watcher?.cancel()
            item.watcher = nil
        }
    }

    enum FileSystemClientError: Error {
        case fileNotExist
    }
}
