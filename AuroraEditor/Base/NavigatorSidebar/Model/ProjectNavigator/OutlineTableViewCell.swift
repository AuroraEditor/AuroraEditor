//
//  OutlineTableViewCell.swift
//  AuroraEditor
//
//  Created by Lukas Pistrol on 07.04.22.
//

import SwiftUI

/// A `NSTableCellView` showing an ``icon`` and a ``label``
final class OutlineTableViewCell: NSTableCellView {

    var label: NSTextField!
    var changeLabel: NSTextField!
    var icon: NSImageView!
    var fileItem: WorkspaceClient.FileItem!

    var changeLabelLargeWidth: NSLayoutConstraint!
    var changeLabelSmallWidth: NSLayoutConstraint!

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

    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)

        // Create the label
        label = SpecialSelectTextField(frame: .zero)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.drawsBackground = false
        label.isBordered = false
        label.isEditable = true
        label.isSelectable = true
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

    func addModel(directoryURL: URL) {
        changeLabel.stringValue = fileItem.gitStatus?.description ?? ""
        changeLabelIsSmall = changeLabel.stringValue.isEmpty
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
