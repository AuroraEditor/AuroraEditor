//
//  FileSystemOutlineView.swift
//  Aurora Editor
//
//  Created by TAY KAI QUAN on 14/8/22.
//  Copyright © 2023 Aurora Company. All rights reserved.
//

import SwiftUI

class FileSystemTableViewCell: StandardTableViewCell {

    /// The `FileItem` the cell represents.
    var fileItem: FileSystemClient.FileItem!

    /// Change label large width constraint
    var changeLabelLargeWidth: NSLayoutConstraint!

    /// Change label small width constraint
    var changeLabelSmallWidth: NSLayoutConstraint!

    private var versionControl: VersionControlModel = .shared

    /// Application preferences
    private let prefs = AppPreferencesModel.shared.preferences.general

    /// Initializes the `OutlineTableViewCell` with an `icon` and `label`
    /// Both the icon and label will be colored, and sized based on the user's preferences.
    /// 
    /// - Parameters:
    ///   - frameRect: The frame of the cell.
    ///   - item: The file item the cell represents.
    ///   - isEditable: Set to true if the user should be able to edit the file name.
    /// 
    /// - Returns: An `OutlineTableViewCell` with the given `FileItem`.
    init(
        frame frameRect: NSRect,
        item: FileSystemClient.FileItem?,
        isVersionControl: Bool = false,
        workspace: WorkspaceDocument?,
        isEditable: Bool = true
    ) {
        super.init(
            frame: frameRect,
            isEditable: isEditable,
            workspace: workspace
        )
        if let item = item {
            addIcon(item: item)
        }

        Task {
            await matchChangedFilesWithLocalFiles()
        }

        addModel()
    }

    /// Configures the label with the given `NSTextField` and sets the delegate to `self`.
    /// 
    /// - Parameter label: The label to configure.
    /// - Parameter isEditable: Set to true if the user should be able to edit the file name.
    override func configLabel(
        label: NSTextField,
        isEditable: Bool
    ) {
        super.configLabel(
            label: label,
            isEditable: isEditable
        )
        label.delegate = self
    }

    /// Adds an icon to the cell.
    /// 
    /// - Parameter item: The `FileItem` to add the icon for.
    func addIcon(item: FileItem) {
        var imageName = item.systemImage
        if item.watcherCode == nil {
            imageName = "exclamationmark.arrow.triangle.2.circlepath"
        }
        if item.watcher == nil && !item.activateWatcher() {
            // watcher failed to activate
            imageName = "eye.trianglebadge.exclamationmark"
        }
        guard let image = NSImage(
            systemSymbolName: imageName,
            accessibilityDescription: nil
        ) else {
            return
        }
        fileItem = item
        fileIcon.image = image
        fileIcon.contentTintColor = color(for: item)
        toolTip = item.fileName
        label.stringValue = label(for: item)
    }

    /// Adds a model to the cell.
    func addModel() {
        secondaryLabel.stringValue = fileItem.gitStatus?.description ?? ""
        if secondaryLabel.stringValue == "?" { secondaryLabel.stringValue = "A" }
    }

    /// Initializes the cell.
    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        fatalError("""
            init(frame: ) isn't implemented on `OutlineTableViewCell`.
            Please use `.init(frame: NSRect, item: FileSystemClient.FileItem?)
            """)
    }

    /// Initializes the cell.
    required init?(coder: NSCoder) {
        fatalError("""
            init?(coder: NSCoder) isn't implemented on `OutlineTableViewCell`.
            Please use `.init(frame: NSRect, item: FileSystemClient.FileItem?)
            """)
    }

    /// Returns the font size for the current row height. Defaults to `13.0`
    private var fontSize: Double {
        switch self.frame.height {
        case 20: return 11
        case 22: return 13
        case 24: return 14
        default: return 13
        }
    }

    /// Generates a string based on user's file name preferences.
    /// 
    /// - Parameter item: The FileItem to generate the name for.
    /// 
    /// - Returns: A `String` with the name to display.
    func label(for item: FileSystemClient.FileItem) -> String {
        switch prefs.fileExtensionsVisibility {
        case .hideAll:
            return item.fileName(typeHidden: true)
        case .showAll:
            return item.fileName(typeHidden: false)
        case .showOnly:
            return item.fileName(typeHidden: !prefs.shownFileExtensions.extensions.contains(item.fileType.rawValue))
        case .hideOnly:
            return item.fileName(typeHidden: prefs.hiddenFileExtensions.extensions.contains(item.fileType.rawValue))
        }
    }

    /// Get the appropriate color for the items icon depending on the users preferences.
    /// 
    /// - Parameter item: The `FileItem` to get the color for
    /// 
    /// - Returns: A `NSColor` for the given `FileItem`.
    func color(for item: FileSystemClient.FileItem) -> NSColor {
        if item.children == nil && prefs.fileIconStyle == .color {
            return NSColor(item.iconColor)
        } else {
            return .controlAccentColor
        }
    }

    /// Match changed files from the upstream repository with local file URLs.
    ///
    /// This function uses a Trie data structure to efficiently compare the paths of changed files
    /// from the upstream repository with the local file URLs. If a match is found, it sets
    /// the `arrowDownIcon.image` to indicate that the file has upstream changes.
    ///
    /// - Important: This method will return early if the workspace is not set or if the arrow down icon
    ///              image cannot be created.
    public func matchChangedFilesWithLocalFiles() async {
        guard let workspace = workspace,
              let arrowDownIconImage = NSImage(
                systemSymbolName: "arrow.down",
                accessibilityDescription: nil
              ) else {
            return
        }

        let changedUpstreamFiles = versionControl.changedUpstreamFiles

        let trie = Trie()
        for file in changedUpstreamFiles {
            let path = workspace.folderURL.appendingPathComponent(String(file)).path
            trie.insert(path)
        }

        if trie.search(fileItem.url.path) {
            upstreamChangesPullIcon.image = arrowDownIconImage
            upstreamChangesPullIcon.contentTintColor = NSColor.secondaryLabelColor
        }
    }
}

/// Red color for error
let errorRed = NSColor(red: 1, green: 0, blue: 0, alpha: 0.2)

extension FileSystemTableViewCell: NSTextFieldDelegate {
    /// Control text did change
    /// 
    /// - Parameter obj: The notification object.
    func controlTextDidChange(_ obj: Notification) {
        label.backgroundColor = validateFileName(for: label?.stringValue ?? "") ? .none : errorRed
    }

    /// Control text did end editing
    /// 
    /// - Parameter obj: The notification object.
    func controlTextDidEndEditing(_ obj: Notification) {
        label.backgroundColor = validateFileName(for: label?.stringValue ?? "") ? .none : errorRed
        if validateFileName(for: label?.stringValue ?? "") {
            fileItem.move(to: fileItem.url.deletingLastPathComponent()
                .appendingPathComponent(label?.stringValue ?? ""))
        } else {
            label?.stringValue = fileItem.fileName
        }
    }

    /// Validate the file name
    /// 
    /// - Parameter newName: The new name to validate.
    /// 
    /// - Returns: A `Bool` indicating if the file name is valid.
    func validateFileName(for newName: String) -> Bool {
        guard newName != fileItem.fileName else { return true }

        guard !newName.isEmpty && newName.isValidFilename &&
              !FileSystemClient.FileItem.fileManger.fileExists(atPath:
                    fileItem.url.deletingLastPathComponent().appendingPathComponent(newName).path)
        else { return false }

        return true
    }
}

extension String {
    /// Check if the string is a valid file name
    var isValidFilename: Bool {
        let regex = "[^:]"
        let testString = NSPredicate(format: "SELF MATCHES %@", regex)
        return !testString.evaluate(with: self)
    }
}
