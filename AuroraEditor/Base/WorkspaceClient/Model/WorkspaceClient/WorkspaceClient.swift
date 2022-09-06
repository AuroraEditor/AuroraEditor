//
//  WorkspaceClient.swift
//  AuroraEditor
//
//  Created by TAY KAI QUAN on 13/8/22.
//

import Combine
import Foundation

// A interface that is used accross AuroraEditor to access
// contents of the WorkspaceClient.
public class WorkspaceClient {

    // TODO: Turn into class variables
    /// callback function that is run when a change is detected in the file system.
    /// This usually contains a `reloadData` function.
    public var onRefresh: () -> Void = {}

    // Variables for the outside to interface with
    public var getFiles: AnyPublisher<[FileItem], Never> =
        CurrentValueSubject<[FileItem], Never>([]).eraseToAnyPublisher()
    public var folderURL: URL?
    public var model: SourceControlModel?

    // These should be private but some functions need them public :(
    public var fileManager: FileManager
    public var ignoredFilesAndFolders: [String]
    public let workspaceItem: FileItem
    public var flattenedFileItems: [String: FileItem]
    private var subject = CurrentValueSubject<[FileItem], Never>([])

    /// A function that, given a file's path, returns a `FileItem` if it exists
    /// within the scope of the `WorkspaceClient`.
    /// - Parameter id: The file's full path
    /// - Returns: The file item corresponding to the file
    public func getFileItem(_ id: String) throws -> FileItem {        guard let item = flattenedFileItems[id] else {
            throw WorkspaceClientError.fileNotExist
        }

        return item
    }

    /// Usually run when the owner of the `WorkspaceClient` doesn't need it anymore.
    /// This de-inits most functions in the `WorkspaceClient`, so that in case it isn't de-init'd it does not use up
    /// significant amounts of RAM.
    public func cleanUp() {
        stopListeningToDirectory()
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
        // Something has changed inside the directory
        // We should reload the files.
        guard !isRunning else { // this runs when a file change is detected but is already running
            anotherInstanceRan += 1
            return
        }
        isRunning = true

        // inital reload of files
        _ = try? rebuildFiles(fromItem: sourceFileItem)

        // re-reload if another instance tried to run while this instance was running
        while anotherInstanceRan > 0 { // TODO: optimise
            let somethingChanged = try? rebuildFiles(fromItem: workspaceItem)
            anotherInstanceRan = !(somethingChanged ?? false) ? 0 : anotherInstanceRan - 1
        }

        // reload git changes
        model?.reloadChangedFiles()
        for changedFile in (model?.changed ?? []) {
            flattenedFileItems[changedFile.id]?.gitStatus = changedFile.gitStatus
        }

        subject.send(workspaceItem.children ?? [])
        isRunning = false
        anotherInstanceRan = 0

        // reload data in outline view controller through the main thread
        DispatchQueue.main.async {
            self.onRefresh()
        }
    }

    /// A function to kill the watcher of a specific directory, or all directories.
    /// - Parameter directory: The directory to stop watching, or nil to stop watching everything.
    func stopListeningToDirectory(directory: URL? = nil) {
        if directory != nil {
            flattenedFileItems[directory!.relativePath]?.watcher?.cancel()
        } else {
            for item in flattenedFileItems.values {
                item.watcher?.cancel()
                item.watcher = nil
            }
        }
    }

    // MARK: Init
    // For some strange reason, swiftlint thinks this is wrong?
    public init(fileManager: FileManager,
                folderURL: URL,
                ignoredFilesAndFolders: [String],
                model: SourceControlModel?) {
        self.fileManager = fileManager
        self.folderURL = folderURL
        self.ignoredFilesAndFolders = ignoredFilesAndFolders
        self.model = model

        // workspace fileItem
        workspaceItem = FileItem(url: folderURL, children: [])
        flattenedFileItems = [workspaceItem.id: workspaceItem]

        self.getFiles = subject
            .handleEvents(receiveCancel: {
                for item in self.flattenedFileItems.values {
                    item.watcher?.cancel()
                    item.watcher = nil
                }
            })
            .receive(on: RunLoop.main)
            .eraseToAnyPublisher()

        workspaceItem.watcherCode = { sourceFileItem in
            self.reloadFromWatcher(sourceFileItem: sourceFileItem)
        }
        reloadFromWatcher(sourceFileItem: workspaceItem)
        workspaceItem.workspaceClient = self
    }
    // swiftlint:enable vertical_parameter_alignment

    enum WorkspaceClientError: Error {
        case fileNotExist
    }
}
