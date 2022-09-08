//
//  StandardTableViewCell.swift
//  AuroraEditor
//
//  Created by TAY KAI QUAN on 17/8/22.
//  Copyright © 2022 Aurora Company. All rights reserved.
//

import SwiftUI

class StandardTableViewCell: NSTableCellView {

    var label: NSTextField!
    var secondaryLabel: NSTextField!
    var icon: NSImageView!

    var workspace: WorkspaceDocument?

    private let prefs = AppPreferencesModel.shared.preferences.general

    /// Initializes the `OutlineTableViewCell` with an `icon` and `label`
    /// Both the icon and label will be colored, and sized based on the user's preferences.
    /// - Parameters:
    ///   - frameRect: The frame of the cell.
    ///   - item: The file item the cell represents.
    ///   - isEditable: Set to true if the user should be able to edit the file name.
    init(frame frameRect: NSRect, isEditable: Bool = true) {
        super.init(frame: frameRect)
        setupViews(frame: frameRect, isEditable: isEditable)
    }

    // Default init, assumes isEditable to be false
    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        setupViews(frame: frameRect, isEditable: false)
    }

    private func setupViews(frame frameRect: NSRect, isEditable: Bool) {
        // Create the label
        label = createLabel()
        configLabel(label: self.label, isEditable: isEditable)
        addSubview(label)
        self.textField = label

        // Create the secondary label
        secondaryLabel = createSecondaryLabel()
        configSecondaryLabel(secondaryLabel: secondaryLabel)
        addSubview(secondaryLabel)

        // Create the icon
        icon = createIcon()
        configIcon(icon: icon)
        addSubview(icon)
        imageView = icon

        // add constraints
        createConstraints(frame: frameRect)
    }

    // MARK: Create and config stuff
    func createLabel() -> NSTextField {
        return SpecialSelectTextField(frame: .zero)
    }

    func configLabel(label: NSTextField, isEditable: Bool) {
        label.translatesAutoresizingMaskIntoConstraints = false
        label.drawsBackground = false
        label.isBordered = false
        label.isEditable = isEditable
        label.isSelectable = isEditable
        label.layer?.cornerRadius = 10.0
        label.font = .labelFont(ofSize: fontSize)
        label.lineBreakMode = .byTruncatingMiddle
    }

    func createSecondaryLabel() -> NSTextField {
        return NSTextField(frame: .zero)
    }

    func configSecondaryLabel(secondaryLabel: NSTextField) {
        secondaryLabel.translatesAutoresizingMaskIntoConstraints = false
        secondaryLabel.drawsBackground = false
        secondaryLabel.isBordered = false
        secondaryLabel.isEditable = false
        secondaryLabel.isSelectable = false
        secondaryLabel.layer?.cornerRadius = 10.0
        secondaryLabel.font = .boldSystemFont(ofSize: fontSize)
        secondaryLabel.alignment = .center
        secondaryLabel.textColor = NSColor(Color.secondary)
    }

    func createIcon() -> NSImageView {
        return NSImageView(frame: .zero)
    }

    func configIcon(icon: NSImageView) {
        icon.translatesAutoresizingMaskIntoConstraints = false
        icon.symbolConfiguration = .init(pointSize: fontSize, weight: .regular, scale: .medium)
    }

    func createConstraints(frame frameRect: NSRect) {
        resizeSubviews(withOldSize: .zero)
    }

    override func resizeSubviews(withOldSize oldSize: NSSize) {
        super.resizeSubviews(withOldSize: oldSize)

        icon.frame = NSRect(x: 2, y: 4,
                            width: 22, height: frame.height)
        Log.info("Middle: \(icon.frame.midX)")

        label.frame = NSRect(x: icon.frame.maxX, y: 4,
                             width: frame.width - icon.frame.width - 1, height: 25)
        
        secondaryLabel.frame = .zero
    }

    /// *Not Implemented*
    required init?(coder: NSCoder) {
        fatalError("""
            init?(coder: NSCoder) isn't implemented on `StandardTableViewCell`.
            Please use `.init(frame: NSRect, isEditable: Bool)
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
