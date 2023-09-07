//
//  FileItem.swift
//  Aurora Editor
//
//  Created by Marco Carnevali on 16/03/22.
//  Copyright © 2023 Aurora Company. All rights reserved.
//
//  This file originates from CodeEdit, https://github.com/CodeEditApp/CodeEdit

import Foundation
import SwiftUI
import UniformTypeIdentifiers
import Version_Control

public extension FileSystemClient {
    enum FileItemCodingKeys: String, CodingKey {
        case id
        case url
        case children
        case changeType
    }

    /// An object containing all necessary information and actions for a specific file in the workspace.
    final class FileItem: Identifiable, Codable, Hashable, Comparable, TabBarItemRepresentable, GitFileItem {
        public var tabID: TabBarItemID { .codeEditor(id) }

        public var title: String { url.lastPathComponent }

        public var icon: Image { Image(systemName: systemImage) }

        public var shouldBeExpanded: Bool = false

        public typealias ID = String

        public var fileIdentifier = UUID().uuidString

        public var watcher: DispatchSourceFileSystemObject?
        public var watcherCode: ((FileItem) -> Void)?

        public var gitStatus: GitType?
        public var fileSystemClient: FileSystemClient?

        // MARK: - Initialization

        public init(url: URL,
                    children: [FileItem]? = nil,
                    changeType: GitType? = nil,
                    fileSystemClient: FileSystemClient? = nil) {
            self.url = url
            self.children = children
            self.gitStatus = changeType
            self.fileSystemClient = fileSystemClient
            id = url.relativePath
        }

        // MARK: - Codable

        public required init(from decoder: Decoder) throws {
            let values = try decoder.container(keyedBy: FileItemCodingKeys.self)
            id = try values.decode(String.self, forKey: .id)
            url = try values.decode(URL.self, forKey: .url)
            children = try values.decode([FileItem]?.self, forKey: .children)
            gitStatus = try values.decode(GitType.self, forKey: .changeType)
        }

        public func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: FileItemCodingKeys.self)
            try container.encode(id, forKey: .id)
            try container.encode(url, forKey: .url)
            try container.encode(children, forKey: .children)
            try container.encode(gitStatus, forKey: .changeType)
        }

        public func activateWatcher() -> Bool {
            do {
                // Check that there is watcher code and that opening the file succeeded
                guard let watcherCode = watcherCode else { return false }
                let descriptor = try openFileDescriptor()

                // Create the source
                let source = DispatchSource.makeFileSystemObjectSource(
                    fileDescriptor: descriptor,
                    eventMask: .write,
                    queue: DispatchQueue.global()
                )

                if descriptor > 2000 {
                    Log.warning("File descriptor \(descriptor) may be exhausted for \(url.path)")
                }

                source.setEventHandler { [weak self] in
                    watcherCode(self!)
                }

                source.setCancelHandler {
                    close(descriptor)
                }

                source.resume()
                self.watcher = source

                // TODO: Reindex the current item because the files in the item may have changed
                // since the initial load on startup.
                return true
            } catch {
                Log.error("Error while activating watcher for \(url.path): \(error)")
                return false
            }
        }

        private func openFileDescriptor() throws -> Int32 {
            let descriptor = open(self.url.path, O_EVTONLY)
            if descriptor == -1 {
                Log.error("Failed to open file descripter")
            }
            return descriptor
        }

        /// The id of the ``FileSystemClient/FileSystemClient/FileItem``.
        ///
        /// This is equal to `url.relativePath`
        public var id: ID

        /// Returns the URL of the ``FileSystemClient/FileSystemClient/FileItem``
        public var url: URL

        /// Returns the children of the current ``FileSystemClient/FileSystemClient/FileItem``.
        ///
        /// If the current ``FileSystemClient/FileSystemClient/FileItem`` is a file this will be `nil`.
        /// If it is an empty folder this will be an empty array.
        public var children: [FileItem]?

        /// Returns a parent ``FileSystemClient/FileSystemClient/FileItem``.
        ///
        /// If the item already is the top-level ``FileSystemClient/FileSystemClient/FileItem`` this returns `nil`.
        public weak var parent: FileItem?

        /// A boolean that is true if ``children`` is not `nil`
        public var isFolder: Bool {
            url.hasDirectoryPath
        }

        /// A boolean that is true if the file item is the root folder of the workspace.
        public var isRoot: Bool {
            parent == nil
        }

        /// A boolean that is true if the file item actually exists in the file system
        public var doesExist: Bool { FileItem.fileManger.fileExists(atPath: self.url.path) }

        /// Returns a string describing a SFSymbol for the current ``FileSystemClient/FileSystemClient/FileItem``
        ///
        /// Use it like this
        /// ```swift
        /// Image(systemName: item.systemImage)
        /// ```
        public var systemImage: String {
            if let children = children {
                // item is a folder
                return folderIcon(children)
            } else {
                // item is a file
                return FileIcon.fileIcon(fileType: fileType)
            }
        }

        /// Returns the file name (e.g.: `Package.swift`)
        public var fileName: String {
            url.lastPathComponent
        }

        /// Returns the extension of the file or an empty string if no extension is present.
        public var fileType: FileIcon.FileType {
            .init(rawValue: url.pathExtension) ?? .txt
        }

        public var changeTypeValue: String {
            gitStatus?.description ?? ""
        }

        var debugFileHeirachy: String { childrenDescription(tabCount: 0) }

        func childrenDescription(tabCount: Int = 0) -> String {
            let indent = String(repeating: "|  ", count: max(tabCount - 1, 0)) + (tabCount != 0 ? "╰--" : "")
            var details = "\(indent)\(url.path)"

            if isFolder {
                details += children?.reduce("") { result, child in
                    result + "\n" + child.childrenDescription(tabCount: tabCount + 1)
                } ?? ""
            }

            return details
        }

        /// Returns a string describing a SFSymbol for folders
        ///
        /// If it is the top-level folder this will return `"square.dashed.inset.filled"`.
        /// If it is a `.codeedit` folder this will return `"folder.fill.badge.gearshape"`.
        /// If it has children this will return `"folder.fill"` otherwise `"folder"`.
        private func folderIcon(_ children: [FileItem]) -> String {
            switch (self.parent, self.fileName) {
            case (nil, _):
                return "square.dashed.inset.filled"
            case (_, ".auroraeditor"):
                return "folder.fill.badge.gearshape"
            default:
                return children.isEmpty ? "folder" : "folder.fill"
            }
        }

        /// Returns the file name with optional extension (e.g.: `Package.swift`)
        public func fileName(typeHidden: Bool) -> String {
            typeHidden ? url.deletingPathExtension().lastPathComponent : fileName
        }

        /// Return the file's UTType
        public var contentType: UTType? {
            try? url.resourceValues(forKeys: [.contentTypeKey]).contentType
        }

        /// Returns a `Color` for a specific `fileType`
        ///
        /// If not specified otherwise this will return `Color.accentColor`
        public var iconColor: Color {
            FileIcon.iconColor(fileType: fileType)
        }

        // MARK: Statics
        /// The default `FileManager` instance
        public static let fileManger = FileManager.default

        // MARK: Intents
        /// Allows the user to view the file or folder in the finder application
        public func showInFinder() {
            NSWorkspace.shared.activateFileViewerSelecting([url])
        }

        /// Allows the user to launch the file or folder as it would be in finder
        public func openWithExternalEditor() {
            NSWorkspace.shared.open(url)
        }

        public func flattenedChildren(depth: Int, ignoringFolders: Bool) -> [FileItem] {
            guard depth > 0 else { return [] }

            var childItems: [FileItem] = []

            if !ignoringFolders || isFolder {
                childItems.append(self)
            }

            guard isFolder else { return childItems }

            if let children = children {
                for child in children {
                    childItems.append(contentsOf: child.flattenedChildren(depth: depth - 1,
                                                                          ignoringFolders: ignoringFolders))
                }
            }

            return childItems
        }

        public func flattenedSiblings(toHeight height: Int, ignoringFolders: Bool) -> [FileItem] {
            var currentFileItem = self

            // Traverse up the hierarchy to the desired height or the root
            for _ in stride(from: 0, to: height, by: 1) {
                guard let parent = currentFileItem.parent else {
                    break  // Reached the root
                }
                currentFileItem = parent
            }

            // Return the flattened children at the specified height
            return currentFileItem.flattenedChildren(depth: height, ignoringFolders: ignoringFolders)
        }

        /// Recursive function that returns the number of children
        /// that contain the `searchString` in their path or their subitems' paths.
        /// Returns `0` if the item is not a folder.
        /// - Parameter searchString: The string
        /// - Parameter ignoredStrings: The prefixes to ignore if they prefix file names
        /// - Returns: The number of children that match the conditiions
        public func appearanceWithinChildrenOf(searchString: String, ignoredStrings: [String] = [".", "~"]) -> Int {
            guard isFolder else { return 0 }

            var count = 0

            for child in children ?? [] {
                if isIgnored(child.fileName, ignoredStrings) {
                    continue
                }

                if searchString.isEmpty {
                    count += 1
                    continue
                }

                if child.isFolder {
                    count += child.appearanceWithinChildrenOf(searchString: searchString)
                } else {
                    count += child.fileName.localizedCaseInsensitiveContains(searchString) ? 1 : 0
                }
            }

            return count
        }

        private func isIgnored(_ fileName: String, _ ignoredStrings: [String]) -> Bool {
            for ignoredString in ignoredStrings where fileName.hasPrefix(ignoredString) {
                return true
            }
            return false
        }

        /// Function that returns an array of the children
        /// that contain the `searchString` in their path or their subitems' paths.
        /// Similar to `appearanceWithinChildrenOf(searchString: String)`
        /// Returns `[]` if the item is not a folder.
        /// - Parameter searchString: The string
        /// - Parameter ignoredStrings: The prefixes to ignore if they prefix file names
        /// - Returns: The children that match the conditiions
        public func childrenSatisfying(searchString: String, ignoredStrings: [String] = [".", "~"]) -> [FileItem] {
            guard isFolder else { return [] }

            let satisfyingChildren = children?.filter { child in
                !isIgnored(child.fileName, ignoredStrings) &&
                (searchString.isEmpty || child.satisfiesSearch(searchString))
            }

            return satisfyingChildren ?? []
        }

        private func satisfiesSearch(_ searchString: String) -> Bool {
            if searchString.isEmpty {
                return true
            }

            if isFolder {
                return appearanceWithinChildrenOf(searchString: searchString) > 0
            } else {
                return fileName.localizedCaseInsensitiveContains(searchString)
            }
        }

        public func hash(into hasher: inout Hasher) {
            hasher.combine(fileIdentifier)
            hasher.combine(id)
        }

        // MARK: - Comparable

        public static func == (lhs: FileSystemClient.FileItem, rhs: FileSystemClient.FileItem) -> Bool {
            return lhs.id == rhs.id
        }

        public static func < (lhs: FileSystemClient.FileItem, rhs: FileSystemClient.FileItem) -> Bool {
            return lhs.url.path < rhs.url.path
        }
    }
}
