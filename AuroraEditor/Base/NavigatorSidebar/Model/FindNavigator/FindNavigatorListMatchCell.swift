//
//  FindNavigatorListCell.swift
//  Aurora Editor
//
//  Created by Khan Winter on 7/7/22.
//

import SwiftUI

/// A `NSTableCellView` showing an icon and label
final class FindNavigatorListMatchCell: NSTableCellView {

    private var label: NSTextField!
    private var icon: NSImageView!
    private var matchItem: SearchResultMatchModel

    init(frame: CGRect, matchItem: SearchResultMatchModel) {
        self.matchItem = matchItem
        super.init(frame: CGRect(x: frame.origin.x,
                                 y: frame.origin.y,
                                 width: frame.width,
                                 height: CGFloat.greatestFiniteMagnitude))

        label = NSTextField(wrappingLabelWithString: matchItem.lineContent)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.drawsBackground = false
        label.isBordered = false
        label.isEditable = false
        label.isSelectable = false
        label.layer?.cornerRadius = 10.0
        label.allowsDefaultTighteningForTruncation = false
        label.cell?.truncatesLastVisibleLine = true
        label.cell?.wraps = true
        label.cell?.font = .labelFont(ofSize: 11)
        label.maximumNumberOfLines = 3
        label.attributedStringValue = matchItem.attributedLabel()
        label.font = .labelFont(ofSize: 11)
        addSubview(label)

        // Create the icon
        icon = NSImageView(frame: .zero)
        icon.translatesAutoresizingMaskIntoConstraints = false
        icon.symbolConfiguration = .init(pointSize: 11,
                                              weight: .regular,
                                              scale: .medium)
        icon.image = NSImage(systemSymbolName: "text.alignleft", accessibilityDescription: nil)
        icon.contentTintColor = NSColor.secondaryLabelColor
        addSubview(icon)
        imageView = icon

        // Constraints
        NSLayoutConstraint.activate([
            label.leadingAnchor.constraint(equalTo: icon.trailingAnchor, constant: 4),
            label.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -2),
            label.topAnchor.constraint(equalTo: topAnchor, constant: 4),
            label.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -4),

            icon.leadingAnchor.constraint(equalTo: leadingAnchor, constant: -2),
            icon.topAnchor.constraint(equalTo: label.topAnchor, constant: 2),
            icon.widthAnchor.constraint(equalToConstant: 16),
            icon.heightAnchor.constraint(equalToConstant: 16)
        ])
    }

    required init?(coder: NSCoder) {
        fatalError()
    }
}
