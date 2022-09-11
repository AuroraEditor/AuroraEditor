//
//  TabHierarchyTableViewCell.swift
//  AuroraEditor
//
//  Created by TAY KAI QUAN on 11/9/22.
//  Copyright © 2022 Aurora Company. All rights reserved.
//

import SwiftUI

class TabHierarchyTableViewCell: StandardTableViewCell {

    var tabItem: TabBarItemID?

    func addTabItem(tabItem: TabBarItemID) {
        self.tabItem = tabItem
        let tabItemRepresentable = workspace?.selectionState.getItemByTab(id: tabItem)
        switch tabItem {
        case .codeEditor:
            icon.image = NSImage(systemSymbolName: "folder", accessibilityDescription: nil)
            textField?.stringValue = "Unknown Code File"
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
        }

        if let tabItemRepresentable = tabItemRepresentable {
            textField?.stringValue = tabItemRepresentable.title
        }
    }
}
