//
//  FileItemFileSystemFunctions.swift
//  AuroraEditor
//
//  Created by TAY KAI QUAN on 6/8/22.
//  Copyright © 2022 Aurora Company. All rights reserved.
//

import Foundation
import SwiftUI

public typealias FileItem = WorkspaceClient.FileItem

extension FileItem {
    /// This function allows creation of folders in the main directory or sub-folders
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

        // Check if folder, if it is create file under self
        var fileUrl = (self.isFolder ?
                    self.url.appendingPathComponent("\(fileName)\(idealExtension)") :
                    self.url.deletingLastPathComponent().appendingPathComponent("\(fileName)\(idealExtension)"))

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

    /// This function deletes the item or folder from the current project
    public func delete() {
        // This function also has to account for how the
        // - file system can change outside of the editor
        let deleteConfirmation = NSAlert()
        let message = "\(self.fileName)\(self.isFolder ? " and its children" :"")"
        deleteConfirmation.messageText = "Do you want to move \(message) to the bin?"
        deleteConfirmation.alertStyle = .critical
        deleteConfirmation.addButton(withTitle: "Delete")
        deleteConfirmation.buttons.last?.hasDestructiveAction = true
        deleteConfirmation.addButton(withTitle: "Cancel")
        if deleteConfirmation.runModal() == .alertFirstButtonReturn { // "Delete" button
            if FileItem.fileManger.fileExists(atPath: self.url.path) {
                do {
                    try FileItem.fileManger.removeItem(at: self.url)
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
            fileUrl = fileUrl.deletingLastPathComponent().appendingPathComponent("\(previousName) copy")
        }

        if FileItem.fileManger.fileExists(atPath: self.url.path) {
            do {
                try FileItem.fileManger.copyItem(at: self.url, to: fileUrl)
            } catch {
                Log.error("Error at \(self.url.path) to \(fileUrl.path)")
                fatalError(error.localizedDescription)
            }
        }
    }

    /// This function moves the item or folder if possible
    public func move(to newLocation: URL) {
        guard !FileItem.fileManger.fileExists(atPath: newLocation.path) else { return }
        do {
            try FileItem.fileManger.moveItem(at: self.url, to: newLocation)
        } catch { fatalError(error.localizedDescription) }
    }
}
