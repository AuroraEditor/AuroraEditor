//
//  EditableListTableViewCell.swift
//  AuroraEditor
//
//  Created by Nanashi Li on 2023/01/13.
//  Copyright © 2023 Aurora Company. All rights reserved.
//

import SwiftUI

class EditableListTableViewCell: NSTableCellView {

    var label: NSTextField!

    private var prefs = AppPreferencesModel.shared.preferences.general

    init(frame frameRect: NSRect, itemName: String, isEditable: Bool = true) {
        super.init(frame: frameRect)
        setupViews(frame: frameRect, isEditable: isEditable, stringValue: itemName)
    }

    private func setupViews(frame frameRect: NSRect, isEditable: Bool, stringValue: String) {
        // Create the label
        label = createLabel()
        configLabel(label: self.label, isEditable: isEditable, value: stringValue)
        self.textField = label

        // add constraints
        createConstraints(frame: frameRect)
        addSubview(label)
    }

    // MARK: Create and config stuff
    func createLabel() -> NSTextField {
        return SpecialSelectTextField(frame: .zero)
    }

    func configLabel(label: NSTextField, isEditable: Bool, value: String) {
        label.translatesAutoresizingMaskIntoConstraints = false
        label.drawsBackground = false
        label.isBordered = false
        label.isEditable = isEditable
        label.isSelectable = isEditable
        label.layer?.cornerRadius = 10.0
        label.font = .labelFont(ofSize: 13)
        label.lineBreakMode = .byTruncatingMiddle
        label.stringValue = value
    }

    func createConstraints(frame frameRect: NSRect) {
        resizeSubviews(withOldSize: .zero)
    }

    override func resizeSubviews(withOldSize oldSize: NSSize) {
        super.resizeSubviews(withOldSize: oldSize)

        let mainLabelWidth = label.frame.size.width
        let newSize = label.sizeThatFits(CGSize(width: mainLabelWidth,
                                                height: CGFloat.greatestFiniteMagnitude))
        label.frame = NSRect(x: 2,
                             y: 2.5,
                             width: newSize.width,
                             height: 25)
    }

    /// *Not Implemented*
    required init?(coder: NSCoder) {
        fatalError("""
            init?(coder: NSCoder) isn't implemented on `StandardTableViewCell`.
            Please use `.init(frame: NSRect, isEditable: Bool)
            """)
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

    func controlTextDidChange(_ obj: Notification) {
        label.backgroundColor = !label.stringValue.isEmpty ? .none : errorRed
    }
    func controlTextDidEndEditing(_ obj: Notification) {
        let oldValue: String = label.stringValue
        label.backgroundColor = !label.stringValue.isEmpty ? .none : errorRed
        if !label.stringValue.isEmpty {
            if !prefs.hiddenFilesAndFolders.contains(label.stringValue) {
                prefs.hiddenFilesAndFolders.append(label.stringValue)
            } else {
                label?.stringValue = oldValue
            }
        } else {
            label?.stringValue = oldValue
        }
    }
}
