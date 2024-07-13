//
//  StandardTableViewCell.swift
//  Aurora Editor
//
//  Created by TAY KAI QUAN on 17/8/22.
//  Copyright © 2023 Aurora Company. All rights reserved.
//

import SwiftUI

/// A standard table cell view that is used in the navigator sidebar.
class StandardTableViewCell: NSTableCellView {

    /// The label of the cell
    var label: NSTextField!

    /// The secondary label of the cell
    var secondaryLabel: NSTextField!

    /// The icon of the cell
    var fileIcon: NSImageView!

    /// The arrow down icon next to the secondary label
    var upstreamChangesPullIcon: NSImageView!

    /// The workspace document
    var workspace: WorkspaceDocument?

    /// The file item the cell represents
    var secondaryLabelRightAligned: Bool = true {
        didSet {
            resizeSubviews(withOldSize: .zero)
        }
    }

    /// The application preferences
    private let prefs = AppPreferencesModel.shared.preferences.general

    /// Initializes the `TableViewCell` with an `icon` and `label`
    /// Both the icon and label will be colored, and sized based on the user's preferences.
    /// 
    /// - Parameters:
    ///   - frameRect: The frame of the cell.
    ///   - isEditable: Set to true if the user should be able to edit the file name.
    init(
        frame frameRect: NSRect,
        isEditable: Bool = true,
        workspace: WorkspaceDocument?
    ) {
        super.init(frame: frameRect)
        setupViews(
            frame: frameRect,
            isEditable: isEditable
        )

        if let workspace = workspace {
            self.workspace = workspace
        }
    }

    // Default init, assumes isEditable to be false
    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        setupViews(frame: frameRect, isEditable: false)
    }

    /// Set up the views
    /// 
    /// - Parameter frameRect: the frame
    /// - Parameter isEditable: whether the cell is editable
    private func setupViews(frame frameRect: NSRect, isEditable: Bool) {
        // Create the label
        label = createLabel()
        configLabel(label: self.label, isEditable: isEditable)
        self.textField = label

        // Create the secondary label
        secondaryLabel = createSecondaryLabel()
        configSecondaryLabel(
            secondaryLabel: secondaryLabel,
            fontSize: 11
        )

        // Create the main icon
        fileIcon = createIcon()
        configIcon(
            icon: fileIcon,
            pointSize: fontSize,
            weight: .regular,
            scale: .medium
        )

        // Create the arrow down icon
        upstreamChangesPullIcon = createIcon()
        configIcon(
            icon: upstreamChangesPullIcon,
            pointSize: 11,
            weight: .bold,
            scale: .small
        )

        // Add subviews
        addSubview(fileIcon)
        addSubview(label)
        addSubview(secondaryLabel)
        addSubview(upstreamChangesPullIcon)

        imageView = fileIcon

        // Add constraints
        createConstraints(frame: frameRect)
    }

    // MARK: Create and config stuff

    /// Create the label
    func createLabel() -> NSTextField {
        return NSTextField(frame: .zero)
    }

    /// Configure label
    /// 
    /// - Parameter label: label
    /// - Parameter isEditable: whether the cell is editable
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

    /// Create secondary label
    func createSecondaryLabel() -> NSTextField {
        return NSTextField(frame: .zero)
    }

    /// Configure secondary label
    /// 
    /// - Parameter secondaryLabel: secondary label
    func configSecondaryLabel(
        secondaryLabel: NSTextField,
        fontSize: CGFloat
    ) {
        secondaryLabel.translatesAutoresizingMaskIntoConstraints = false
        secondaryLabel.drawsBackground = false
        secondaryLabel.isBordered = false
        secondaryLabel.isEditable = false
        secondaryLabel.isSelectable = false
        secondaryLabel.layer?.cornerRadius = 10.0
        secondaryLabel.font = .systemFont(
            ofSize: fontSize,
            weight: .bold
        )
        secondaryLabel.alignment = .center
        secondaryLabel.textColor = NSColor(Color.secondary)
    }

    /// Create icon
    func createIcon() -> NSImageView {
        return NSImageView(frame: .zero)
    }

    /// Configure icon
    /// 
    /// - Parameter icon: icon
    func configIcon(
        icon: NSImageView,
        pointSize: CGFloat,
        weight: NSFont.Weight,
        scale: NSImage.SymbolScale
    ) {
        icon.translatesAutoresizingMaskIntoConstraints = false
        icon.symbolConfiguration = .init(
            pointSize: pointSize,
            weight: weight,
            scale: scale
        )
        icon.contentTintColor = NSColor(Color.secondary)
    }

    /// Create constraints
    /// 
    /// - Parameter frameRect: the frame
    func createConstraints(frame frameRect: NSRect) {
        resizeSubviews(withOldSize: .zero)
    }

    // MARK: Layout
    /// The width of the icon
    let iconWidth: CGFloat = 22
    let smallIconWidth: CGFloat = 16
    let arrowDownIconWidth: CGFloat = 7

    /// Resize the subviews
    /// 
    /// - Parameter oldSize: the old size
    override func resizeSubviews(withOldSize oldSize: NSSize) { // swiftlint:disable:this function_body_length
        super.resizeSubviews(withOldSize: oldSize)

        fileIcon.frame = NSRect(
            x: 2,
            y: 4,
            width: iconWidth,
            height: frame.height
        )
        if let alignmentRect = fileIcon.image?.alignmentRect {
            fileIcon.frame = NSRect(
                x: (iconWidth + 4 - alignmentRect.width) / 2,
                y: 4,
                width: alignmentRect.width,
                height: frame.height
            )
        }

        if secondaryLabelRightAligned {
            // Calculate the size of the secondaryLabel
            let secondLabelWidth = secondaryLabel.frame.size.width
            let newSize = secondaryLabel.sizeThatFits(
                CGSize(
                    width: secondLabelWidth,
                    height: CGFloat.greatestFiniteMagnitude
                )
            )

            // Determine the x-position for the secondaryLabel and upstreamChangesPullIcon
            let secondaryLabelXPosition: CGFloat
            if newSize.width > 0 {
                secondaryLabelXPosition = frame.width - newSize.width - arrowDownIconWidth - 6
                secondaryLabel.frame = NSRect(
                    x: secondaryLabelXPosition + arrowDownIconWidth + 2,
                    y: (frame.height - newSize.height) / 2,
                    width: newSize.width + 7.5,
                    height: newSize.height
                )
            } else {
                secondaryLabelXPosition = frame.width - arrowDownIconWidth - 6
                secondaryLabel.frame = NSRect.zero
            }

            upstreamChangesPullIcon.frame = NSRect(
                x: secondaryLabelXPosition,
                y: (frame.height - newSize.height),
                width: arrowDownIconWidth,
                height: frame.height
            )

            label.frame = NSRect(
                x: iconWidth + 2,
                y: 2.5,
                width: secondaryLabelXPosition - fileIcon.frame.maxX - 5,
                height: 25
            )
        } else {
            let mainLabelWidth = label.frame.size.width
            let newSize = label.sizeThatFits(CGSize(width: mainLabelWidth,
                                                    height: CGFloat.greatestFiniteMagnitude))
            label.frame = NSRect(
                x: iconWidth + 2,
                y: 2.5,
                width: newSize.width,
                height: 25
            )
            secondaryLabel.frame = NSRect(
                x: label.frame.maxX + 2,
                y: 2.5,
                width: frame.width - label.frame.maxX - 2,
                height: 25
            )
        }
    }

    /// Initializes the cell.
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
}
