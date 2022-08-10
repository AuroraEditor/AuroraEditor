//
//  WorkspaceClientLive.swift
//  AuroraEditorModules/WorkspaceClient
//
//  Created by Marco Carnevali on 16/03/22.
//
import Combine
import Foundation

public extension WorkspaceClient {
    /// Default instance of WorkspaceClient
    /// - Parameters:
    ///   - fileManager: a `FileManager` instance
    ///   - folderURL: The root folder
    ///   - ignoredFilesAndFolders: An array of file and folder names to exclude
    ///   - onUpdate: A closure that is run when the file system changes.
    /// - Returns: A WorkspaceClient instance
    static func `default`( // swiftlint:disable:this function_body_length
        fileManager: FileManager,
        folderURL: URL,
        ignoredFilesAndFolders: [String],
        model: SourceControlModel?,
        onUpdate: @escaping () -> Void = {}
    ) throws -> Self {
        var flattenedFileItems: [String: FileItem] = [:]

        // This is the object that the subscriber will watch
        let subject = CurrentValueSubject<[FileItem], Never>([])

        var isRunning: Bool = false
        var anotherInstanceRan: Int = 0

        // workspace fileItem
        let workspaceItem = FileItem(url: folderURL, children: [])
        flattenedFileItems[workspaceItem.id] = workspaceItem

        // this weird statement is so that watcherCode's closure does not contain watcherCode when it is uninitialised
        var watcherCode: (FileItem) -> Void = { _ in }; watcherCode = { sourceFileItem in
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
            _ = model?.reloadChangedFiles()
            for changedFile in (model?.changed ?? []) {
                flattenedFileItems[changedFile.id]?.gitStatus = changedFile.gitStatus
            }

            // run the onUpdate function after changes have been made
            onUpdate()

            subject.send(workspaceItem.children ?? [])
            isRunning = false
            anotherInstanceRan = 0

            // reload data in outline view controller through the main thread
            DispatchQueue.main.async { onRefresh() }
        }
        workspaceItem.watcherCode = watcherCode
        workspaceItem.watcherCode(workspaceItem)

        /// Recursive loading of files into `FileItem`s
        /// - Parameter url: The URL of the directory to load the items of
        /// - Returns: `[FileItem]` representing the contents of the directory
        func loadFiles(fromURL url: URL) throws -> [FileItem] {
            let directoryContents = try fileManager.contentsOfDirectory(at: url, includingPropertiesForKeys: nil)
            var items: [FileItem] = []
            for itemURL in directoryContents {
                // Skip file if it is in ignore list
                guard !ignoredFilesAndFolders.contains(itemURL.lastPathComponent) else { continue }

                var isDir: ObjCBool = false

                if fileManager.fileExists(atPath: itemURL.path, isDirectory: &isDir) {
                    var subItems: [FileItem]?

                    if isDir.boolValue {
                        // Recursively fetch subdirectories and files if the path points to a directory
                        subItems = try loadFiles(fromURL: itemURL)
                    }

                    let newFileItem = FileItem(url: itemURL,
                                               children: subItems?.sortItems(foldersOnTop: true))
                    // note: watcher code will be applied after the workspaceItem is created
                    newFileItem.watcherCode = watcherCode
                    subItems?.forEach { $0.parent = newFileItem }
                    items.append(newFileItem)
                    flattenedFileItems[newFileItem.id] = newFileItem
                }
            }

            return items
        }

        /// Recursive function similar to `loadFiles`, but creates or deletes children of the
        /// `FileItem` so that they are accurate with the file system, instead of creating an
        /// entirely new `FileItem`, to prevent the `OutlineView` from going crazy with folding.
        /// - Parameter fileItem: The `FileItem` to correct the children of
        func rebuildFiles(fromItem fileItem: FileItem) throws -> Bool {
            var didChangeSomething = false

            // get the actual directory children
            let directoryContentsUrls = try fileManager.contentsOfDirectory(at: fileItem.url,
                                                                            includingPropertiesForKeys: nil)

            // test for deleted children, and remove them from the index
            for oldContent in fileItem.children ?? [] where !directoryContentsUrls.contains(oldContent.url) {
                if let removeAt = fileItem.children?.firstIndex(of: oldContent) {
                    fileItem.children?[removeAt].watcher?.cancel()
                    fileItem.children?.remove(at: removeAt)
                    flattenedFileItems.removeValue(forKey: oldContent.id)
                    didChangeSomething = true
                }
            }

            // test for new children, and index them using loadFiles
            for newContent in directoryContentsUrls {
                guard !ignoredFilesAndFolders.contains(newContent.lastPathComponent) else { continue }

                // if the child has already been indexed, continue to the next item.
                guard !(fileItem.children?.map({ $0.url }).contains(newContent) ?? false) else { continue }

                var isDir: ObjCBool = false
                if fileManager.fileExists(atPath: newContent.path, isDirectory: &isDir) {
                    var subItems: [FileItem]?

                    if isDir.boolValue { subItems = try loadFiles(fromURL: newContent) }

                    let newFileItem = FileItem(url: newContent,
                                               children: subItems?.sortItems(foldersOnTop: true))
                    newFileItem.watcherCode = watcherCode
                    subItems?.forEach { $0.parent = newFileItem }
                    newFileItem.parent = fileItem
                    flattenedFileItems[newFileItem.id] = newFileItem
                    fileItem.children?.append(newFileItem)
                    didChangeSomething = true
                }
            }

            fileItem.children = fileItem.children?.sortItems(foldersOnTop: true)
            fileItem.children?.forEach({
                if $0.isFolder {
                    let childChanged = try? rebuildFiles(fromItem: $0)
                    didChangeSomething = (childChanged ?? false) ? true : didChangeSomething
                }
                flattenedFileItems[$0.id] = $0
            })

            return didChangeSomething
        }

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

        return Self(
            folderURL: { folderURL },
            getFiles: subject
                .handleEvents(receiveCancel: {
                    stopListeningToDirectory()
                })
                .receive(on: RunLoop.main)
                .eraseToAnyPublisher(),
            getFileItem: { id in
                // TODO: Can crash on save.
                guard let item = flattenedFileItems[id] else {
                    throw WorkspaceClientError.fileNotExist
                }
                return item
            },
            cleanUp: {
                stopListeningToDirectory()
                workspaceItem.children = []
                flattenedFileItems = [workspaceItem.id: workspaceItem]
                Log.info("Cleaned up watchers and file items")
            },
            model: model
        )
    }
}
