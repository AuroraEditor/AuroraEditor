//
//  AuroraEditorWindowController+NSToolbarDelegate.swift
//  AuroraEditor
//
//  Created by TAY KAI QUAN on 3/9/22.
//  Copyright © 2022 Aurora Company. All rights reserved.
//

import Cocoa
import SwiftUI

extension AuroraEditorWindowController: NSToolbarDelegate {

    func setupToolbar() {
        let toolbar = NSToolbar(identifier: UUID().uuidString)
        toolbar.delegate = self
        toolbar.displayMode = .labelOnly
        toolbar.showsBaselineSeparator = false
        self.window?.titleVisibility = .hidden
        self.window?.toolbarStyle = .unifiedCompact
        if prefs.preferences.general.tabBarStyle == .native {
            // Set titlebar background as transparent by default in order to
            // style the toolbar background in native tab bar style.
            self.window?.titlebarAppearsTransparent = true
            self.window?.titlebarSeparatorStyle = .none
        } else {
            // In xcode tab bar style, we use default toolbar background with
            // line separator.
            self.window?.titlebarAppearsTransparent = false
            self.window?.titlebarSeparatorStyle = .automatic
        }
        self.window?.toolbar = toolbar
    }

    func toolbarDefaultItemIdentifiers(_ toolbar: NSToolbar) -> [NSToolbarItem.Identifier] {
        [
            .toggleFirstSidebarItem,
            .flexibleSpace,
            .runApplication,
            .sidebarTrackingSeparator,
            .branchPicker,
            .flexibleSpace,
            .toolbarAppInformation,
            .flexibleSpace,
            .libraryPopup,
            .toggleLastSidebarItem
        ]
    }

    func toolbarAllowedItemIdentifiers(_ toolbar: NSToolbar) -> [NSToolbarItem.Identifier] {
        [
            .toggleFirstSidebarItem,
            .flexibleSpace,
            .runApplication,
            .sidebarTrackingSeparator,
            .branchPicker,
            .flexibleSpace,
            .toolbarAppInformation,
            .flexibleSpace,
            .libraryPopup,
            .itemListTrackingSeparator,
            .toggleLastSidebarItem
        ]
    }

    // swiftlint:disable:next function_body_length
    func toolbar(
        _ toolbar: NSToolbar,
        itemForItemIdentifier itemIdentifier: NSToolbarItem.Identifier,
        willBeInsertedIntoToolbar flag: Bool
    ) -> NSToolbarItem? {
        switch itemIdentifier {
        case .itemListTrackingSeparator:
                guard let splitViewController = splitViewController else {
                    return nil
                }

                return NSTrackingSeparatorToolbarItem(
                    identifier: NSToolbarItem.Identifier.itemListTrackingSeparator,
                    splitView: splitViewController.splitView,
                    dividerIndex: 1
                )
        case .toggleFirstSidebarItem:
            let toolbarItem = NSToolbarItem(itemIdentifier: NSToolbarItem.Identifier.toggleFirstSidebarItem)
            toolbarItem.label = "Navigator Sidebar"
            toolbarItem.paletteLabel = "Navigator Sidebar"
            toolbarItem.toolTip = "Hide or show the Navigator"
            toolbarItem.isBordered = true
            toolbarItem.target = self
            toolbarItem.action = #selector(self.toggleFirstPanel)
            toolbarItem.image = NSImage(
                systemSymbolName: "sidebar.leading",
                accessibilityDescription: nil
            )?.withSymbolConfiguration(.init(scale: .large))

            return toolbarItem
        case .runApplication:
            let toolbarItem = NSToolbarItem(itemIdentifier: NSToolbarItem.Identifier.runApplication)
            toolbarItem.label = "Run Application"
            toolbarItem.paletteLabel = "Run Application"
            toolbarItem.toolTip = "Start the active scheme"
            toolbarItem.isEnabled = false
            toolbarItem.target = self
            toolbarItem.image = NSImage(systemSymbolName: "play.fill",
                                        accessibilityDescription: nil)?.withSymbolConfiguration(.init(scale: .small))

            return toolbarItem
        case .toolbarAppInformation:
            let toolbarItem = NSToolbarItem(itemIdentifier: NSToolbarItem.Identifier.toolbarAppInformation)
            let view = NSHostingView(
                rootView: ToolbarAppInfo()
            )
            toolbarItem.view = view

            return toolbarItem
        case .toggleLastSidebarItem:
            let toolbarItem = NSToolbarItem(itemIdentifier: NSToolbarItem.Identifier.toggleLastSidebarItem)
            toolbarItem.label = "Inspector Sidebar"
            toolbarItem.paletteLabel = "Inspector Sidebar"
            toolbarItem.toolTip = "Hide or show the Inspectors"
            toolbarItem.isBordered = true
            toolbarItem.target = self
            toolbarItem.action = #selector(self.toggleLastPanel)
            toolbarItem.image = NSImage(
                systemSymbolName: "sidebar.trailing",
                accessibilityDescription: nil
            )?.withSymbolConfiguration(.init(scale: .large))

            return toolbarItem
        case .branchPicker:
            let toolbarItem = NSToolbarItem(itemIdentifier: NSToolbarItem.Identifier.branchPicker)
            let view = NSHostingView(
                rootView: ToolbarBranchPicker(fileSystemClient: workspace.fileSystemClient)
            )
            toolbarItem.view = view

            return toolbarItem
        case .libraryPopup:
            let toolbarItem = NSToolbarItem(
                itemIdentifier: NSToolbarItem.Identifier.libraryPopup
            )
            toolbarItem.label = "Library"
            toolbarItem.paletteLabel = "Library"
            toolbarItem.toolTip = "Library"
            toolbarItem.isEnabled = false
            toolbarItem.target = self
            toolbarItem.image = NSImage(
                systemSymbolName: "plus",
                accessibilityDescription: nil
            )?.withSymbolConfiguration(
                .init(scale: .small)
            )

            return toolbarItem
        default:
            return NSToolbarItem(itemIdentifier: itemIdentifier)
        }
    }

    @objc func toggleFirstPanel() {
        guard let firstSplitView = splitViewController.splitViewItems.first else { return }
        firstSplitView.animator().isCollapsed.toggle()

        for (id, AEExt) in ExtensionsManager.shared.loadedExtensions {
            Log.info(id, "didToggleNavigatorPane()")
            AEExt.respond(
                action: "didToggleNavigatorPane",
                parameters: [
                    "opened": !firstSplitView.animator().isCollapsed
                ])
        }
    }

    @objc func toggleLastPanel() {
        guard let lastSplitView = splitViewController.splitViewItems.last,
              let toolbar = window?.toolbar
        else { return }

        lastSplitView.animator().isCollapsed.toggle()
        for (id, AEExt) in ExtensionsManager.shared.loadedExtensions {
            Log.info(id, "didToggleInspectorPane()")
            AEExt.respond(
                action: "didToggleInspectorPane",
                parameters: [
                    "opened": !lastSplitView.animator().isCollapsed
                ])
        }

        let itemCount = toolbar.items.count
        if lastSplitView.isCollapsed {
            toolbar.removeItem(at: itemCount-3) // -1 is the last item, -2 is the second last
            toolbar.removeItem(at: itemCount-3) // this removes the second last and the third last
        } else {
            toolbar.insertItem(
                withItemIdentifier: NSToolbarItem.Identifier.itemListTrackingSeparator,
                at: itemCount-1 // insert it as second last
            )
            toolbar.insertItem(
                withItemIdentifier: NSToolbarItem.Identifier.flexibleSpace,
                at: itemCount-0 // insert it as "last" (actually second last now)
            )
        }
    }
}

private extension NSToolbarItem.Identifier {
    static let toggleFirstSidebarItem = NSToolbarItem.Identifier("ToggleFirstSidebarItem")
    static let toggleLastSidebarItem = NSToolbarItem.Identifier("ToggleLastSidebarItem")
    static let itemListTrackingSeparator = NSToolbarItem.Identifier("ItemListTrackingSeparator")
    static let branchPicker = NSToolbarItem.Identifier("BranchPicker")
    static let libraryPopup = NSToolbarItem.Identifier("LibraryPopup")
    static let runApplication = NSToolbarItem.Identifier("RunApplication")
    static let toolbarAppInformation = NSToolbarItem.Identifier("ToolbarAppInformation")
}
