//
//  WorkflowTableViewCell.swift
//  AuroraEditor
//
//  Created by Nanashi Li on 2022/09/18.
//  Copyright © 2022 Aurora Company. All rights reserved.
//

import AppKit
import Version_Control

/// A `NSTableCellView` showing an ``icon`` and a ``label``
final class WorkflowTableViewCell: StandardTableViewCell {

    init(frame frameRect: NSRect, item: Workflow? = nil) {
        super.init(frame: frameRect)

        // Add text and image
        var image = NSImage()

        label.stringValue = item?.name ?? ""
        secondaryLabel.lineBreakMode = .byTruncatingMiddle
        secondaryLabel.stringValue = item?.path ?? ""
        secondaryLabel.lineBreakMode = .byTruncatingMiddle

        self.secondaryLabelRightAlignmed = false

        image = NSImage(systemSymbolName: "diamond", accessibilityDescription: nil)!
        icon.image = image
        icon.contentTintColor = .gray

        resizeSubviews(withOldSize: .zero)
    }

    required init?(coder: NSCoder) {
        fatalError("""
            init?(coder: NSCoder) isn't implemented on `WorkflowTableViewCell`.
            Please use `.init(frame: NSRect)
            """)
    }
}
