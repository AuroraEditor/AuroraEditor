//
//  FileItemFileSystemFunctions.swift
//  Aurora Editor
//
//  Created by TAY KAI QUAN on 6/8/22.
//  Copyright © 2023 Aurora Company. All rights reserved.
//

import Foundation
import SwiftUI

/// File Item
public typealias FileItem = FileSystemClient.FileItem

extension FileItem {
    /// This function allows creation of folders in the main directory or sub-folders
    /// 
    /// - Parameter folderName: The name of the new folder
    public func addFolder(folderName: String) {
        // Check if folder, if it is create folder under self, else create on same level.
        var folderUrl = (self.isFolder ?
                         self.url.appendingPathComponent(folderName) :
                            self.url.deletingLastPathComponent().appendingPathComponent(folderName))

        // If a file/folder with the same name exists, add a number to the end.
        var fileNumber = 0
        while FileItem.fileManger.fileExists(atPath: folderUrl.path) {
            fileNumber += 1
            folderUrl = folderUrl.deletingLastPathComponent().appendingPathComponent("\(folderName)\(fileNumber)")
        }

        // Create the folder
        do {
            try FileItem.fileManger.createDirectory(at: folderUrl,
                                                    withIntermediateDirectories: true,
                                                    attributes: [:])
        } catch {
            fatalError(error.localizedDescription)
        }
    }

    /// This function allows creating files in the selected folder or project main directory
    /// 
    /// - Parameter fileName: The name of the new file
    public func addFile(fileName: String) {
        // check the folder for other files, and see what the most common file extension is
        var fileExtensions: [String: Int] = ["": 0]

        for child in (self.isFolder ?
                      self.flattenedSiblings(height: 2, ignoringFolders: true) :
                      parent?.flattenedSiblings(height: 2, ignoringFolders: true)) ?? [] where !child.isFolder {
            // if the file extension was present before, add it now
            let childFileName = child.fileName(typeHidden: false)
            if let index = childFileName.lastIndex(of: ".") {
                let childFileExtension = ".\(childFileName.suffix(from: index).dropFirst())"
                fileExtensions[childFileExtension] = (fileExtensions[childFileExtension] ?? 0) + 1
            } else {
                fileExtensions[""] = (fileExtensions[""] ?? 0) + 1
            }
        }

        var largestValue = 0
        var idealExtension = ""
        for (extName, count) in fileExtensions where count > largestValue {
            idealExtension = extName
            largestValue = count
        }

        var fileUrl = nearestFolder.appendingPathComponent("\(fileName)\(idealExtension)")
        // If a file/folder with the same name exists, add a number to the end.
        var fileNumber = 0
        while FileItem.fileManger.fileExists(atPath: fileUrl.path) {
            fileNumber += 1
            fileUrl = fileUrl.deletingLastPathComponent()
                .appendingPathComponent("\(fileName)\(fileNumber)\(idealExtension)")
        }

        // Create the file
        FileItem.fileManger.createFile(
            atPath: fileUrl.path,
            contents: nil,
            attributes: [FileAttributeKey.creationDate: Date()]
        )
    }

    /// Nearest folder refers to the parent directory if this is a non-folder item, or itself if the item is a folder.
    var nearestFolder: URL {
        (self.isFolder ?
                    self.url :
                    self.url.deletingLastPathComponent())
    }

    /// This function deletes the item or folder from the current project
    @MainActor
    public func delete() {
        // This function also has to account for how the
        // - file system can change outside of the editor
        let deleteConfirmation = NSAlert()
        let message = "\(self.fileName)\(self.isFolder ? " and its children" : "")"
        deleteConfirmation.messageText = "Do you want to move \(message) to the bin?"
        deleteConfirmation.alertStyle = .critical
        deleteConfirmation.addButton(withTitle: "Delete")
        deleteConfirmation.buttons.last?.hasDestructiveAction = true
        deleteConfirmation.addButton(withTitle: "Cancel")
        if deleteConfirmation.runModal() == .alertFirstButtonReturn { // "Delete" button
            if FileItem.fileManger.fileExists(atPath: self.url.path) {
                do {
                    try FileItem.fileManger.trashItem(
                        at: self.url,
                        resultingItemURL: nil
                    )
                } catch {
                    fatalError(error.localizedDescription)
                }
            }
        }
    }

    /// This function duplicates the item or folder
    public func duplicate() {
        // If a file/folder with the same name exists, add "copy" to the end
        var fileUrl = self.url
        while FileItem.fileManger.fileExists(atPath: fileUrl.path) {
            let previousName = fileUrl.lastPathComponent
            let fileExtension = fileUrl.pathExtension.isEmpty ? "" : ".\(fileUrl.pathExtension)"
            let fileName = fileExtension.isEmpty ? previousName :
                previousName.replacingOccurrences(of: ".\(fileExtension)", with: "")
            fileUrl = fileUrl.deletingLastPathComponent().appendingPathComponent("\(fileName) copy\(fileExtension)")
        }
        self.logger.info("Duplicating file to \(fileUrl)")

        if FileItem.fileManger.fileExists(atPath: self.url.path) {
            do {
                try FileItem.fileManger.copyItem(at: self.url, to: fileUrl)
            } catch {
                self.logger.fault("Error at \(self.url.path) to \(fileUrl.path)")
                fatalError(error.localizedDescription)
            }
        }
    }

    /// This function moves the item or folder if possible
    /// 
    /// - Parameter newLocation: The new location of the item
    public func move(to newLocation: URL) {
        guard !FileItem.fileManger.fileExists(atPath: newLocation.path) else { return }
        createMissingParentDirectory(for: newLocation.deletingLastPathComponent())

        do {
            self.logger.info("Moving file \(self.url.debugDescription) to \(newLocation.debugDescription)")
            try FileItem.fileManger.moveItem(at: self.url, to: newLocation)
        } catch { fatalError(error.localizedDescription) }

        // This function recursively creates missing directories if the file is moved to a directory that does not exist
        func createMissingParentDirectory(for url: URL, createSelf: Bool = true) {
            // if the folder's parent folder doesn't exist, create it.
            if !FileItem.fileManger.fileExists(atPath: url.deletingLastPathComponent().path) {
                createMissingParentDirectory(for: url.deletingLastPathComponent())
            }
            // if the folder doesn't exist and the function was ordered to create it, create it.
            if createSelf && !FileItem.fileManger.fileExists(atPath: url.path) {
                self.logger.info("Creating folder \(url.debugDescription)")
                // Create the folder
                do {
                    try FileItem.fileManger.createDirectory(at: url,
                                                            withIntermediateDirectories: true,
                                                            attributes: [:])
                } catch {
                    fatalError(error.localizedDescription)
                }
            }
        }
    }
}
