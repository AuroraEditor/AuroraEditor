//
//  SourceControlTableViewCell.swift
//  Aurora Editor
//
//  Created by Nanashi Li on 2022/08/10.
//  Copyright © 2023 Aurora Company. All rights reserved.
//

import SwiftUI

/// Source control table view cell.
final class SourceControlTableViewCell: FileSystemTableViewCell {
    /// Initialize the cell.
    /// 
    /// - Parameter frameRect: the frame
    /// - Parameter item: the item
    /// - Parameter isEditable: whether the cell is editable
    /// 
    /// - Returns: the cell
    override init(
        frame frameRect: NSRect,
        item: FileSystemClient.FileItem?,
        isVersionControl: Bool = false,
        workspace: WorkspaceDocument?,
        isEditable _: Bool = false
    ) {
        super.init(
            frame: frameRect,
            item: item,
            isVersionControl: true,
            workspace: workspace,
            isEditable: false
        )
    }

    /// Add an icon to the cell.
    /// 
    /// - Parameter item: the item
    override func addIcon(item: FileItem) {
        guard let image = NSImage(
            systemSymbolName: item.systemImage,
            accessibilityDescription: nil
        ) else { return }

        fileItem = item
        fileIcon.image = image
        fileIcon.contentTintColor = color(for: item)
        toolTip = item.fileName
        label.stringValue = label(for: item)
    }

    /// Add a model to the cell.
    override func addModel() {
        super.addModel()
        // add colour
        if secondaryLabel.stringValue == "A" {
            label.textColor = NSColor(red: 106 / 255, green: 255 / 255, blue: 156 / 255, alpha: 1)
        } else if secondaryLabel.stringValue == "D" {
            label.textColor = NSColor(red: 237 / 255, green: 94 / 255, blue: 122 / 255, alpha: 1)
        }
        resizeSubviews(withOldSize: .zero)
    }

    /// Initialize the cell.
    required init?(coder: NSCoder) {
        fatalError()
    }
}
