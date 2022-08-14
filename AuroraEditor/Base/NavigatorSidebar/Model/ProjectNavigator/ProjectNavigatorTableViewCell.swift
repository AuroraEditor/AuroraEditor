//
//  OutlineTableViewCell.swift
//  AuroraEditor
//
//  Created by Lukas Pistrol on 07.04.22.
//

import SwiftUI

/// A `NSTableCellView` showing an ``icon`` and a ``label``
class ProjectNavigatorTableViewCell: NSTableCellView {

    var label: NSTextField!
    var changeLabel: NSTextField!
    var icon: NSImageView!
    var fileItem: WorkspaceClient.FileItem!

    var changeLabelLargeWidth: NSLayoutConstraint!
    var changeLabelSmallWidth: NSLayoutConstraint!

    var workspace: WorkspaceDocument?

    var changeLabelIsSmall: Bool = true {
        didSet {
            if changeLabelIsSmall { // is small
                changeLabelLargeWidth.isActive = false
                changeLabelSmallWidth.isActive = true
            } else { // is large
                changeLabelLargeWidth.isActive = true
                changeLabelSmallWidth.isActive = false
            }
        }
    }

    private let prefs = AppPreferencesModel.shared.preferences.general

    /// Initializes the `OutlineTableViewCell` with an `icon` and `label`
    /// Both the icon and label will be colored, and sized based on the user's preferences.
    /// - Parameters:
    ///   - frameRect: The frame of the cell.
    ///   - item: The file item the cell represents.
    ///   - isEditable: Set to true if the user should be able to edit the file name.
    init(frame frameRect: NSRect, item: WorkspaceClient.FileItem?, isEditable: Bool = true) {
        super.init(frame: frameRect)

        // Create the label
        label = SpecialSelectTextField(frame: .zero)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.drawsBackground = false
        label.isBordered = false
        label.isEditable = isEditable
        label.isSelectable = isEditable
        label.delegate = self
        label.layer?.cornerRadius = 10.0
        label.font = .labelFont(ofSize: fontSize)
        label.lineBreakMode = .byTruncatingMiddle
        addSubview(label)
        self.textField = label

        // Create the change label
        changeLabel = NSTextField(frame: .zero)
        changeLabel.translatesAutoresizingMaskIntoConstraints = false
        changeLabel.drawsBackground = false
        changeLabel.isBordered = false
        changeLabel.isEditable = false
        changeLabel.isSelectable = false
        changeLabel.layer?.cornerRadius = 10.0
        changeLabel.font = .boldSystemFont(ofSize: fontSize)
        changeLabel.alignment = .center
        changeLabel.textColor = NSColor(Color.secondary)
        addSubview(changeLabel)

        // Create the icon
        icon = NSImageView(frame: .zero)
        icon.translatesAutoresizingMaskIntoConstraints = false
        icon.symbolConfiguration = .init(pointSize: fontSize, weight: .regular, scale: .medium)
        addSubview(icon)
        imageView = icon

        if let item = item {
            addIcon(item: item)
        }
        createConstraints(frame: frameRect)
        addModel()
    }

    func addIcon(item: FileItem) {
        var imageName = item.systemImage
        if item.watcherCode == nil {
            imageName = "exclamationmark.arrow.triangle.2.circlepath"
        }
        if item.watcher == nil && !item.activateWatcher() {
            // watcher failed to activate
            imageName = "eye.trianglebadge.exclamationmark"
        }
        let image = NSImage(systemSymbolName: imageName, accessibilityDescription: nil)!
        fileItem = item
        icon.image = image
        icon.contentTintColor = color(for: item)
        toolTip = item.fileName
        label.stringValue = label(for: item)
    }

    func createConstraints(frame frameRect: NSRect) {
        // Icon constraints
        icon.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: -2).isActive = true
        icon.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        icon.widthAnchor.constraint(equalToConstant: 25).isActive = true
        icon.heightAnchor.constraint(equalToConstant: frameRect.height).isActive = true

        // Label constraints
        label.leadingAnchor.constraint(equalTo: icon.trailingAnchor, constant: 1).isActive = true
        label.trailingAnchor.constraint(equalTo: changeLabel.leadingAnchor, constant: 1).isActive = true
        label.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        label.maximumNumberOfLines = 1
        label.usesSingleLineMode = true

        // change label constraints
        changeLabelLargeWidth = changeLabel.leadingAnchor.constraint(equalTo: self.trailingAnchor, constant: -18)
        changeLabelSmallWidth = changeLabel.leadingAnchor.constraint(equalTo: self.trailingAnchor, constant: 0)
        changeLabelIsSmall = true
        changeLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: 1).isActive = true
        changeLabel.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        changeLabel.maximumNumberOfLines = 1
        changeLabel.usesSingleLineMode = true
    }

    func addModel() {
        changeLabel.stringValue = fileItem.gitStatus?.description ?? ""
        changeLabelIsSmall = changeLabel.stringValue.isEmpty
    }

    /// *Not Implemented*
    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        fatalError("""
            init(frame: ) isn't implemented on `OutlineTableViewCell`.
            Please use `.init(frame: NSRect, item: WorkspaceClient.FileItem?)
            """)
    }

    /// *Not Implemented*
    required init?(coder: NSCoder) {
        fatalError("""
            init?(coder: NSCoder) isn't implemented on `OutlineTableViewCell`.
            Please use `.init(frame: NSRect, item: WorkspaceClient.FileItem?)
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
    /// - Parameter item: The FileItem to generate the name for.
    /// - Returns: A `String` with the name to display.
    func label(for item: WorkspaceClient.FileItem) -> String {
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
    /// - Parameter item: The `FileItem` to get the color for
    /// - Returns: A `NSColor` for the given `FileItem`.
    func color(for item: WorkspaceClient.FileItem) -> NSColor {
        if item.children == nil && prefs.fileIconStyle == .color {
            return NSColor(item.iconColor)
        } else {
            return .secondaryLabelColor
        }
    }

    class SpecialSelectTextField: NSTextField {
//        override func becomeFirstResponder() -> Bool {
            // TODO: Set text range
            // this is the code to get the text range, however I cannot find a way to select it :(
//            NSRange(location: 0, length: stringValue.distance(from: stringValue.startIndex,
//                to: stringValue.lastIndex(of: ".") ?? stringValue.endIndex))
//            return true
//        }
    }
}

let errorRed = NSColor.init(red: 1, green: 0, blue: 0, alpha: 0.2)
extension ProjectNavigatorTableViewCell: NSTextFieldDelegate {
    func controlTextDidChange(_ obj: Notification) {
        label.backgroundColor = validateFileName(for: label?.stringValue ?? "") ? .none : errorRed
    }
    func controlTextDidEndEditing(_ obj: Notification) {
        label.backgroundColor = validateFileName(for: label?.stringValue ?? "") ? .none : errorRed
        if validateFileName(for: label?.stringValue ?? "") {
            fileItem.move(to: fileItem.url.deletingLastPathComponent()
                .appendingPathComponent(label?.stringValue ?? ""))
        } else {
            label?.stringValue = fileItem.fileName
        }
    }

    func validateFileName(for newName: String) -> Bool {
        guard newName != fileItem.fileName else { return true }

        guard !newName.isEmpty && newName.isValidFilename &&
              !WorkspaceClient.FileItem.fileManger.fileExists(atPath:
                    fileItem.url.deletingLastPathComponent().appendingPathComponent(newName).path)
        else { return false }

        return true
    }
}

extension String {
    var isValidFilename: Bool {
        let regex = "[^:]"
        let testString = NSPredicate(format: "SELF MATCHES %@", regex)
        return !testString.evaluate(with: self)
    }
}
