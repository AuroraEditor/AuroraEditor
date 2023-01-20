//
//  SourceControlTableViewCell.swift
//  Aurora Editor
//
//  Created by Nanashi Li on 2022/08/10.
//  Copyright © 2023 Aurora Company. All rights reserved.
//

import SwiftUI

final class SourceControlTableViewCell: FileSystemTableViewCell {

    override init(frame frameRect: NSRect, item: FileSystemClient.FileItem?, isEditable _: Bool = false) {
        super.init(frame: frameRect, item: item, isEditable: false)
    }

    override func addIcon(item: FileItem) {
        let image = NSImage(systemSymbolName: item.systemImage, accessibilityDescription: nil)!
        fileItem = item
        icon.image = image
        icon.contentTintColor = color(for: item)
        toolTip = item.fileName
        label.stringValue = label(for: item)
    }

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

    required init?(coder: NSCoder) {
        fatalError()
    }
}
