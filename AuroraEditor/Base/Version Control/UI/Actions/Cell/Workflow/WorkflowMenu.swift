//
//  WorkflowMenu.swift
//  AuroraEditor
//
//  Created by Nanashi Li on 2022/09/18.
//  Copyright © 2022 Aurora Company. All rights reserved.
//

import SwiftUI
import Version_Control

final class WorkflowMenu: NSMenu {

    typealias Item = Workflow

    var item: Item?

    private let fileManger = FileManager.default

    private var outlineView: NSOutlineView

    init(sender: NSOutlineView) {
        outlineView = sender
        super.init(title: "Git Workflow Options")
    }

    @available(*, unavailable)
    required init(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func menuItem(_ title: String, action: Selector?, key: String = "") -> NSMenuItem {
        let mItem = NSMenuItem(title: title, action: action, keyEquivalent: key)
        mItem.target = self

        return mItem
    }

    private func setupMenu() {

        let editWorkflow = menuItem("Edit Workflow", action: nil)

        let remote = menuItem("View Workflow on Remote", action: nil)

        items = [
            editWorkflow,
            NSMenuItem.separator(),
            remote
        ]
    }
}

extension NSMenuItem {
    fileprivate static func none() -> NSMenuItem {
        let item = NSMenuItem(title: "<None>", action: nil, keyEquivalent: "")
        item.isEnabled = false
        return item
    }

    fileprivate static func propertyList() -> NSMenuItem {
        NSMenuItem(title: "Property List", action: nil, keyEquivalent: "")
    }

    fileprivate static func asciiPropertyList() -> NSMenuItem {
        NSMenuItem(title: "ASCII Property List", action: nil, keyEquivalent: "")
    }

    fileprivate static func hex() -> NSMenuItem {
        NSMenuItem(title: "Hex", action: nil, keyEquivalent: "")
    }

    fileprivate static func quickLook() -> NSMenuItem {
        NSMenuItem(title: "Quick Look", action: nil, keyEquivalent: "")
    }
}
