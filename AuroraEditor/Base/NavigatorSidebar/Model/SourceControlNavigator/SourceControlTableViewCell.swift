//
//  SourceControlTableViewCell.swift
//  AuroraEditor
//
//  Created by Nanashi Li on 2022/08/10.
//  Copyright © 2022 Aurora Company. All rights reserved.
//

import SwiftUI

final class SourceControlTableViewCell: OutlineTableViewCell {

    override init(frame frameRect: NSRect, item: WorkspaceClient.FileItem?, isEditable _ : Bool = false) {
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
