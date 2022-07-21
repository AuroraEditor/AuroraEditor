//
//  OutlineTableViewCell.swift
//  AuroraEditor
//
//  Created by Lukas Pistrol on 07.04.22.
//

import SwiftUI
import WorkspaceClient

/// A `NSTableCellView` showing an ``icon`` and a ``label``
final class OutlineTableViewCell: NSTableCellView {

    var label: NSTextField!
    var changeLabel: NSTextField!
    var icon: NSImageView!
    var fileItem: WorkspaceClient.FileItem!

    var labelTrailingConstraint: NSLayoutConstraint!

    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)

        // Create the label
        self.label = NSTextField(frame: .zero)
        self.label.translatesAutoresizingMaskIntoConstraints = false
        self.label.drawsBackground = false
        self.label.isBordered = false
        self.label.isEditable = true
        self.label.isSelectable = true
        self.label.delegate = self
        self.label.layer?.cornerRadius = 10.0
        self.label.font = .labelFont(ofSize: fontSize)

        self.addSubview(label)
        self.textField = label

        // Create the icon
        self.icon = NSImageView(frame: .zero)
        self.icon.translatesAutoresizingMaskIntoConstraints = false
        self.icon.symbolConfiguration = .init(pointSize: fontSize, weight: .regular, scale: .medium)

        self.addSubview(icon)
        self.imageView = icon

        // Icon constraints
        self.icon.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: -2).isActive = true
        self.icon.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        self.icon.widthAnchor.constraint(equalToConstant: 25).isActive = true
        self.icon.heightAnchor.constraint(equalToConstant: frameRect.height).isActive = true

        // Label constraints
        self.label.leadingAnchor.constraint(equalTo: icon.trailingAnchor, constant: 1).isActive = true
        labelTrailingConstraint = self.label.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: 1)
        labelTrailingConstraint.isActive = true
        self.label.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        self.label.maximumNumberOfLines = 1
        self.label.usesSingleLineMode = true
    }

    func addModel(model: SourceControlModel, directoryURL: URL) {
        for changedFile in model.changed {
            guard "\(directoryURL.path)/\(changedFile.fileLink.path)" == self.fileItem.url.path else { continue }

            // Create the change label
            self.changeLabel = NSTextField(frame: .zero)
            self.changeLabel.translatesAutoresizingMaskIntoConstraints = false
            self.changeLabel.drawsBackground = false
            self.changeLabel.isBordered = false
            self.changeLabel.isEditable = false
            self.changeLabel.isSelectable = false
            self.changeLabel.layer?.cornerRadius = 10.0
            self.changeLabel.font = .boldSystemFont(ofSize: fontSize-1)
            self.changeLabel.alignment = .right
            self.label.addSubview(changeLabel)

            // change label constraints
            self.changeLabel.leadingAnchor.constraint(equalTo: icon.trailingAnchor, constant: 1).isActive = true
            self.changeLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: 1).isActive = true
            self.changeLabel.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
            self.changeLabel.maximumNumberOfLines = 1
            self.changeLabel.usesSingleLineMode = true
            self.changeLabel.stringValue = changedFile.changeTypeValue
            labelTrailingConstraint.constant = 20
            return
        }
        labelTrailingConstraint.constant = 1
    }

    required init?(coder: NSCoder) {
        fatalError()
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
}

let errorRed = NSColor.init(red: 1, green: 0, blue: 0, alpha: 0.2)
extension OutlineTableViewCell: NSTextFieldDelegate {
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
