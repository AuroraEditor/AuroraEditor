//
//  TabHierarchyTableViewCell.swift
//  Aurora Editor
//
//  Created by TAY KAI QUAN on 11/9/22.
//  Copyright © 2023 Aurora Company. All rights reserved.
//

import SwiftUI

/// Tab hierarchy table view cell
class TabHierarchyTableViewCell: StandardTableViewCell {
    /// Tab item ID
    var tabItem: TabBarItemID?

    /// Application preferences
    private let prefs = AppPreferencesModel.shared.preferences.general

    /// Add tab item
    /// 
    /// - Parameter tabItem: the tab item
    func addTabItem(tabItem: TabBarItemID) {
        self.tabItem = tabItem
        let tabItemRepresentable = workspace?.selectionState.getItemByTab(id: tabItem)
        switch tabItem {
        case .codeEditor:
            // set the image
            guard let fileItem = tabItemRepresentable as? FileItem else { break }

            if let image = NSImage(
                systemSymbolName: fileItem.systemImage,
                accessibilityDescription: nil
            ) {
                fileIcon.image = image
            }

            // set the image color and tooltip
            if fileItem.children == nil && prefs.fileIconStyle == .color {
                fileIcon.contentTintColor = NSColor(fileItem.iconColor)
            } else {
                fileIcon.contentTintColor = .secondaryLabelColor
            }
            toolTip = fileItem.fileName
            textField?.stringValue = "Unknown Code File"

            // TODO: get and then set the line number
            secondaryLabel.stringValue = "Line X"
        case .extensionInstallation:
            fileIcon.image = NSImage(systemSymbolName: "puzzlepiece.extension", accessibilityDescription: nil)
            textField?.stringValue = "Unknown Extension"
        case .webTab:
            fileIcon.image = NSImage(systemSymbolName: "globe", accessibilityDescription: nil)
            textField?.stringValue = "Unknown Web Tab"
        case .projectHistory:
            fileIcon.image = NSImage(named: "vault")
            textField?.stringValue = "Project History"
        case .branchHistory:
            fileIcon.image = NSImage(named: "vault")
            textField?.stringValue = "Branch History"
        case .actionsWorkflow:
            fileIcon.image = NSImage(named: "diamond")
            textField?.stringValue = "GitHub Workflows"
        case .extensionCustomView:
            fileIcon.image = NSImage(named: "globe")
            textField?.stringValue = "Extension"
        }

        if let tabItemRepresentable = tabItemRepresentable {
            textField?.stringValue = tabItemRepresentable.title
        }
    }
}
