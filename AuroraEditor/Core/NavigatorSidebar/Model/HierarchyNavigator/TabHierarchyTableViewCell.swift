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
                icon.image = image
            }

            // set the image color and tooltip
            if fileItem.children == nil && prefs.fileIconStyle == .color {
                icon.contentTintColor = NSColor(fileItem.iconColor)
            } else {
                icon.contentTintColor = .secondaryLabelColor
            }
            toolTip = fileItem.fileName
            textField?.stringValue = "Unknown Code File"

            // TODO: get and then set the line number
            secondaryLabel.stringValue = "Line X"
        case .extensionInstallation:
            icon.image = NSImage(systemSymbolName: "puzzlepiece.extension", accessibilityDescription: nil)
            textField?.stringValue = "Unknown Extension"
        case .webTab:
            icon.image = NSImage(systemSymbolName: "globe", accessibilityDescription: nil)
            textField?.stringValue = "Unknown Web Tab"
        case .projectHistory:
            icon.image = NSImage(named: "vault")
            textField?.stringValue = "Project History"
        case .branchHistory:
            icon.image = NSImage(named: "vault")
            textField?.stringValue = "Branch History"
        case .actionsWorkflow:
            icon.image = NSImage(named: "diamond")
            textField?.stringValue = "GitHub Workflows"
        case .extensionCustomView:
            icon.image = NSImage(named: "globe")
            textField?.stringValue = "Extension"
        }

        if let tabItemRepresentable = tabItemRepresentable {
            textField?.stringValue = tabItemRepresentable.title
        }
    }
}
