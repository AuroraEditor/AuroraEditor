//
//  SourceControlTableViewCell.swift
//  AuroraEditor
//
//  Created by Nanashi Li on 2022/08/10.
//  Copyright © 2022 Aurora Company. All rights reserved.
//

import SwiftUI

final class SourceControlTableViewCell: NSTableCellView {

    var label: NSTextField!
    var gitLabel: NSTextField!
    var icon: NSImageView!
    var fileItem: FileItem!

    private var gitLabelLargeWidth: NSLayoutConstraint!
    private var gitLabelSmallWidth: NSLayoutConstraint!

    private var gitLabelIsSmall: Bool = true {
        didSet {
            if gitLabelIsSmall { // is small
                gitLabelLargeWidth.isActive = false
                gitLabelSmallWidth.isActive = true
            } else { // is large
                gitLabelLargeWidth.isActive = true
                gitLabelSmallWidth.isActive = false
            }
        }
    }

    private let prefs = AppPreferencesModel.shared.preferences.general

    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)

        // Create the source control label
        label = NSTextField(frame: .zero)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.drawsBackground = false
        label.isEditable = false
        label.isSelectable = true
        label.delegate = self
        label.layer?.cornerRadius = 10
        label.font = .labelFont(ofSize: fontSize)
        label.lineBreakMode = .byTruncatingMiddle
        addSubview(label)
        self.textField = label

        gitLabel = NSTextField(frame: .zero)
        gitLabel.translatesAutoresizingMaskIntoConstraints = false
        gitLabel.drawsBackground = false
        gitLabel.isBordered = false
        gitLabel.isEditable = false
        gitLabel.isSelectable = false
        gitLabel.layer?.cornerRadius = 10
        gitLabel.font = .boldSystemFont(ofSize: fontSize)
        gitLabel.alignment = .center
        gitLabel.textColor = NSColor(Color.secondary)
        addSubview(gitLabel)

        icon = NSImageView(frame: .zero)
        icon.translatesAutoresizingMaskIntoConstraints = false
        icon.symbolConfiguration = .init(pointSize: fontSize, weight: .regular, scale: .medium)
        addSubview(icon)
        imageView = icon

        createConstraints(frame: frameRect)
    }

    func createConstraints(frame frameRect: NSRect) {
        // Icon constraints
        icon.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: -2).isActive = true
        icon.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        icon.widthAnchor.constraint(equalToConstant: 25).isActive = true
        icon.heightAnchor.constraint(equalToConstant: frameRect.height).isActive = true

        // Label constraints
        label.leadingAnchor.constraint(equalTo: icon.trailingAnchor, constant: 1).isActive = true
        label.trailingAnchor.constraint(equalTo: gitLabel.leadingAnchor, constant: 1).isActive = true
        label.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        label.maximumNumberOfLines = 1
        label.usesSingleLineMode = true

        // change label constraints
        gitLabelLargeWidth = gitLabel.leadingAnchor.constraint(equalTo: self.trailingAnchor, constant: -18)
        gitLabelSmallWidth = gitLabel.leadingAnchor.constraint(equalTo: self.trailingAnchor, constant: 0)
        gitLabelIsSmall = true
        gitLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: 1).isActive = true
        gitLabel.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        gitLabel.maximumNumberOfLines = 1
        gitLabel.usesSingleLineMode = true
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

extension SourceControlTableViewCell: NSTextFieldDelegate {
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
