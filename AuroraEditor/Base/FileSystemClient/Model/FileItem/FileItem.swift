//
//  FileItem.swift
//  Aurora Editor
//
//  Created by Marco Carnevali on 16/03/22.
//  Copyright © 2023 Aurora Company. All rights reserved.
//

import Foundation
import SwiftUI
import UniformTypeIdentifiers
import Version_Control

public extension FileSystemClient {
    /// The coding keys for the ``FileSystemClient``.
    enum FileItemCodingKeys: String, CodingKey {
        /// Identifier
        case id

        /// URL
        case url

        /// Children
        case children

        /// Change type
        case changeType
    }

    /// An object containing all necessary information and actions for a specific file in the workspace
    final class FileItem: Identifiable, Codable, TabBarItemRepresentable, GitFileItem {
        // TODO: Clean this up

        /// Tab identifier
        public var tabID: TabBarItemID { .codeEditor(id) }

        /// Tab title
        public var title: String { url.lastPathComponent }

        /// Tab icon
        public var icon: Image { Image(systemName: systemImage) }

        /// Should be expanded
        public var shouldBeExpanded: Bool = false

        public typealias ID = String

        /// The file identifier
        public var fileIdentifier = UUID().uuidString

        /// The watcher for the file
        public var watcher: DispatchSourceFileSystemObject?

        /// The code that should be executed when the file changes
        public var watcherCode: ((FileItem) -> Void)?

        /// The type of change that has been made to the file
        public var gitStatus: GitType?

        /// The file system client
        public var fileSystemClient: FileSystemClient?

        /// Activates the watcher for the file
        /// 
        /// - Returns: `true` if the watcher was activated successfully
        public func activateWatcher() -> Bool {
            // check that there is watcher code and that opening the file succeeded
            guard let watcherCode = watcherCode else { return false }
            let descriptor = open(self.url.path, O_EVTONLY)
            guard descriptor > 0 else { return false }

            // create the source
            let source = DispatchSource.makeFileSystemObjectSource(
                fileDescriptor: descriptor,
                eventMask: .write,
                queue: DispatchQueue.global()
            )
            if descriptor > 2000 {
                Log.info("Watcher \(descriptor) used up on \(self.url.path)")
            }
            source.setEventHandler { watcherCode(self) }
            source.setCancelHandler { close(descriptor) }
            source.resume()
            self.watcher = source

            // TODO: reindex the current item, because the files in the item may have changed
            // since the initial load on startup.
            return true
        }

        /// Initialises a new FileItem
        /// 
        /// - Parameter url: The URL of the file
        /// - Parameter children: The children of the file
        /// - Parameter changeType: The type of change that has been made to the file
        /// - Parameter fileSystemClient: The file system client
        public init(url: URL,
                    children: [FileItem]? = nil,
                    changeType: GitType? = nil,
                    fileSystemClient: FileSystemClient? = nil
        ) {
            self.url = url
            self.children = children
            self.gitStatus = changeType
            self.fileSystemClient = fileSystemClient
            id = url.relativePath
        }

        /// Initialises a new FileItem
        /// 
        /// - Parameter decoder: The decoder
        public required init(from decoder: Decoder) throws {
            let values = try decoder.container(keyedBy: FileItemCodingKeys.self)
            id = try values.decode(String.self, forKey: .id)
            url = try values.decode(URL.self, forKey: .url)
            children = try values.decode([FileItem]?.self, forKey: .children)
            gitStatus = try values.decode(GitType.self, forKey: .changeType)
        }

        /// Encodes the FileItem
        /// 
        /// - Parameter encoder: The encoder
        public func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: FileItemCodingKeys.self)
            try container.encode(id, forKey: .id)
            try container.encode(url, forKey: .url)
            try container.encode(children, forKey: .children)
            try container.encode(gitStatus, forKey: .changeType)
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

        /// Returns the type of change that has been made to the file
        public var changeTypeValue: String {
            gitStatus?.description ?? ""
        }

        /// Debug file heirachy
        var debugFileHeirachy: String { childrenDescription(tabCount: 0) }

        /// Children description
        /// 
        /// - Parameter tabCount: The tab count
        /// 
        /// - Returns: The children description
        func childrenDescription(tabCount: Int) -> String {
            var myDetails = "\(String(repeating: "|  ", count: max(tabCount - 1, 0)))\(tabCount != 0 ? "╰--" : "")"
            myDetails += "\(url.path)"
            if !self.isFolder { // if im a file, just return the url
                return myDetails
            } else { // if im a folder, return the url and its children's details
                var childDetails = "\(myDetails)"
                for child in children ?? [] {
                    childDetails += "\n\(child.childrenDescription(tabCount: tabCount + 1))"
                }
                return childDetails
            }
        }

        /// Returns a string describing a SFSymbol for folders
        ///
        /// If it is the top-level folder this will return `"square.dashed.inset.filled"`.
        /// If it is a `.codeedit` folder this will return `"folder.fill.badge.gearshape"`.
        /// If it has children this will return `"folder.fill"` otherwise `"folder"`.
        /// 
        /// - Parameter children: The children of the folder
        /// 
        /// - Returns: The SFSymbol string
        private func folderIcon(_ children: [FileItem]) -> String {
            if self.parent == nil {
                return "square.dashed.inset.filled"
            }
            if self.fileName == ".codeedit" {
                return "folder.fill.badge.gearshape"
            }
            return children.isEmpty ? "folder" : "folder.fill"
        }

        /// Returns the file name with optional extension (e.g.: `Package.swift`)
        /// 
        /// - Parameter typeHidden: If `true` the extension will be hidden
        /// 
        /// - Returns: The file name
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

        /// Flattens the children of the current item
        /// 
        /// - Parameter depth: The depth to flatten
        /// - Parameter ignoringFolders: If `true` folders will be ignored
        /// 
        /// - Returns: The flattened children
        public func flattenedChildren(depth: Int, ignoringFolders: Bool) -> [FileItem] {
            guard depth > 0 else { return [] }
            guard isFolder else { return [self] }
            var childItems: [FileItem] = ignoringFolders ? [] : [self]
            children?.forEach { child in
                childItems.append(contentsOf: child.flattenedChildren(depth: depth - 1,
                    ignoringFolders: ignoringFolders))
            }
            return childItems
        }

        /// Flattens the siblings of the current item
        /// 
        /// - Parameter height: The height to flatten
        /// - Parameter ignoringFolders: If `true` folders will be ignored
        /// 
        /// - Returns: The flattened siblings
        public func flattenedSiblings(height: Int, ignoringFolders: Bool) -> [FileItem] {
            var topmostParent = self
            for _ in 0..<height {
                guard let parent = topmostParent.parent else { break }
                topmostParent = parent
            }
            return topmostParent.flattenedChildren(depth: height, ignoringFolders: ignoringFolders)
        }

        /// Recursive function that returns the number of children
        /// that contain the `searchString` in their path or their subitems' paths.
        /// Returns `0` if the item is not a folder.
        /// 
        /// - Parameter searchString: The string
        /// - Parameter ignoredStrings: The prefixes to ignore if they prefix file names
        /// 
        /// - Returns: The number of children that match the conditiions
        public func appearanceWithinChildrenOf(searchString: String,
                                               ignoredStrings: [String] = [".", "~"]) -> Int {
            var count = 0
            guard self.isFolder else { return 0 }
            for child in self.children ?? [] {
                var isIgnored: Bool = false
                for ignoredString in ignoredStrings where child.fileName.hasPrefix(ignoredString) {
                    isIgnored = true // can use regex later
                }

                if isIgnored {
                    continue
                }

                guard !searchString.isEmpty else { count += 1; continue }
                if child.isFolder {
                    count += child.appearanceWithinChildrenOf(searchString: searchString) > 0 ? 1 : 0
                } else {
                    count += child.fileName.lowercased().contains(searchString.lowercased()) ? 1 : 0
                }
            }
            return count
        }

        /// Function that returns an array of the children
        /// that contain the `searchString` in their path or their subitems' paths.
        /// Similar to `appearanceWithinChildrenOf(searchString: String)`
        /// Returns `[]` if the item is not a folder.
        /// 
        /// - Parameter searchString: The string
        /// - Parameter ignoredStrings: The prefixes to ignore if they prefix file names
        /// 
        /// - Returns: The children that match the conditiions
        public func childrenSatisfying(searchString: String,
                                       ignoredStrings: [String] = [".", "~"]) -> [FileItem] {
            var satisfyingChildren: [FileItem] = []
            guard self.isFolder else { return [] }
            for child in self.children ?? [] {
                var isIgnored: Bool = false
                for ignoredString in ignoredStrings where child.fileName.hasPrefix(ignoredString) {
                    isIgnored = true // can use regex later
                }

                if isIgnored {
                    continue
                }

                guard !searchString.isEmpty else { satisfyingChildren.append(child); continue }
                if child.isFolder {
                    if child.appearanceWithinChildrenOf(searchString: searchString) > 0 {
                        satisfyingChildren.append(child)
                    }
                } else {
                    if child.fileName.lowercased().contains(searchString.lowercased()) {
                        satisfyingChildren.append(child)
                    }
                }
            }
            return satisfyingChildren
        }
    }
}

// MARK: Hashable
extension FileSystemClient.FileItem: Hashable {
    /// Hashes the essential components of the file item
    public func hash(into hasher: inout Hasher) {
        hasher.combine(fileIdentifier)
        hasher.combine(id)
    }
}

// MARK: Comparable
extension FileSystemClient.FileItem: Comparable {
    /// Compares two file items
    /// 
    /// - Parameter lhs: The left hand side
    /// - Parameter rhs: The right hand side
    /// 
    /// - Returns: `true` if the two file items are equal
    public static func == (lhs: FileSystemClient.FileItem, rhs: FileSystemClient.FileItem) -> Bool {
        lhs.id == rhs.id
    }

    /// Compares two file items
    /// 
    /// - Parameter lhs: The left hand side
    /// - Parameter rhs: The right hand side
    /// 
    /// - Returns: `true` if the left hand side is less than the right hand side
    public static func < (lhs: FileSystemClient.FileItem, rhs: FileSystemClient.FileItem) -> Bool {
        lhs.url.lastPathComponent < rhs.url.lastPathComponent
    }
}
// swiftlint:disable:this file_length
