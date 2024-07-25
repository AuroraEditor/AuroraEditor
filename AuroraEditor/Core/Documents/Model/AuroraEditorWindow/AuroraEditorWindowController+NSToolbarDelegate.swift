//
//  AuroraEditorWindowController+NSToolbarDelegate.swift
//  Aurora Editor
//
//  Created by TAY KAI QUAN on 3/9/22.
//  Copyright © 2023 Aurora Company. All rights reserved.
//

import SwiftUI

extension AuroraEditorWindowController: NSToolbarDelegate {

    /// Sets up and configures the application's toolbar.
    ///
    /// This function is responsible for creating and configuring the NSToolbar that will be used in the
    /// application's user interface. It sets the toolbar's delegate, display mode, and appearance, as well
    /// as other properties like title visibility and transparency based on user preferences.
    func setupToolbar() {
        // We use a fixed identifier for the toolbar to ensure user customization persistence.
        let toolbar = NSToolbar(identifier: "AEToolbar")
        toolbar.delegate = self
        toolbar.displayMode = .labelOnly
        toolbar.showsBaselineSeparator = false

        self.window?.titleVisibility = .hidden
        self.window?.toolbarStyle = .unifiedCompact

        if prefs.preferences.general.tabBarStyle == .native {
            self.window?.titlebarAppearsTransparent = true
            self.window?.titlebarSeparatorStyle = .none
        } else {
            self.window?.titlebarAppearsTransparent = false
            self.window?.titlebarSeparatorStyle = .automatic
        }

        self.window?.toolbar = toolbar
    }

    /// Returns an array of default toolbar item identifiers to be displayed in the application's toolbar.
    ///
    /// - Parameter toolbar: The NSToolbar instance for which default item identifiers are requested.
    /// - Returns: An array of NSToolbarItem.Identifier values representing the default items for the toolbar.
    ///
    /// This function is part of the NSToolbarDelegate protocol and is called by the toolbar system to determine
    /// the default items that should be displayed in the toolbar. The returned array specifies the default
    /// item identifiers that will appear in the toolbar by default when it is initially set up.
    func toolbarDefaultItemIdentifiers(_ toolbar: NSToolbar) -> [NSToolbarItem.Identifier] {
        [
            .toggleNavigator,
            .flexibleSpace,
            .flexibleSpace,
            .runApplication,
            .sidebarTrackingSeparator,
            .branchPicker,
            .flexibleSpace,
            .toolbarAppInformation,
            .flexibleSpace,
            .libraryPopup,
            .itemListTrackingSeparator,
            .flexibleSpace,
            .toggleInspector
        ]
    }

    /// Returns an array of allowed toolbar item identifiers for customization in the application's toolbar.
    ///
    /// - Parameter toolbar: The NSToolbar instance for which allowed item identifiers are requested.
    /// - Returns: An array of NSToolbarItem.Identifier values representing the items that can be added or
    ///            removed by the user in the toolbar customization panel.
    ///
    /// This function is part of the NSToolbarDelegate protocol and is called by the toolbar system to determine
    /// which items the user is allowed to customize in the toolbar. The returned array specifies the item
    /// identifiers that can be added or removed by the user when customizing the toolbar layout.
    func toolbarAllowedItemIdentifiers(_ toolbar: NSToolbar) -> [NSToolbarItem.Identifier] {
        [
            .toggleNavigator,
            .flexibleSpace,
            .runApplication,
            .sidebarTrackingSeparator,
            .branchPicker,
            .flexibleSpace,
            .toolbarAppInformation,
            .flexibleSpace,
            .libraryPopup,
            .itemListTrackingSeparator,
            .toggleInspector
        ]
    }

    /// Provides toolbar items based on their unique identifiers to be displayed in the application's toolbar.
    ///
    /// - Parameters:
    ///   - toolbar: The NSToolbar instance requesting the item.
    ///   - itemIdentifier: The unique identifier of the requested toolbar item.
    ///   - flag: A Boolean value indicating whether the item will be inserted into the toolbar.
    ///
    /// - Returns: An NSToolbarItem that corresponds to the provided item identifier,
    ///            or nil if the identifier is not recognized.
    ///
    /// This method is part of the NSToolbarDelegate protocol and is called by the toolbar system
    /// when it needs to create an NSToolbarItem for a specific item identifier. You should implement
    /// this method to provide the appropriate toolbar items for your application's toolbar.
    ///
    /// The method uses a switch statement to handle different item identifiers, such as separators, buttons,
    /// or custom views. Depending on the identifier, it creates and configures an NSToolbarItem and returns
    /// it to be displayed in the toolbar.
    ///
    /// Note: If the itemIdentifier is not recognized (i.e., it falls into the 'default' case), the function returns nil
    /// indicating that no toolbar item should be displayed for that identifier.
    func toolbar(// swiftlint:disable:this function_body_length
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
        case .toggleNavigator:
            let toolbarItem = NSToolbarItem(itemIdentifier: NSToolbarItem.Identifier.toggleNavigator)
            toolbarItem.label = "Navigator Sidebar"
            toolbarItem.paletteLabel = "Navigator Sidebar"
            toolbarItem.toolTip = "Hide or show the Navigator"
            toolbarItem.isBordered = true
            toolbarItem.target = self
            toolbarItem.action = #selector(self.toggleNavigatorPane)
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
                rootView: ToolbarAppInfo().environmentObject(workspace)
            )

            let weakWidth = view.widthAnchor.constraint(
                equalToConstant: 760
            )
            weakWidth.priority = .defaultLow

            let strongWidth = view.widthAnchor.constraint(
                greaterThanOrEqualToConstant: 200
            )
            strongWidth.priority = .defaultHigh

            NSLayoutConstraint.activate([
                weakWidth,
                strongWidth
            ])

            toolbarItem.view = view

            return toolbarItem
        case .toggleInspector:
            let toolbarItem = NSToolbarItem(itemIdentifier: NSToolbarItem.Identifier.toggleInspector)
            toolbarItem.label = "Inspector Sidebar"
            toolbarItem.paletteLabel = "Inspector Sidebar"
            toolbarItem.toolTip = "Hide or show the Inspectors"
            toolbarItem.isBordered = true
            toolbarItem.target = self
            toolbarItem.action = #selector(self.toggleInspectorPane)
            toolbarItem.image = NSImage(
                systemSymbolName: "sidebar.trailing",
                accessibilityDescription: nil
            )?.withSymbolConfiguration(.init(scale: .large))

            return toolbarItem
        case .branchPicker:
            let toolbarItem = NSToolbarItem(itemIdentifier: NSToolbarItem.Identifier.branchPicker)
            let view = NSHostingView(
                rootView: ToolbarBranchPicker(
                    workspace: workspace
                )
                .environmentObject(versionControl)
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
            return nil
        }
    }

    /// Toggles the visibility of the navigator pane in the application's user interface.
    ///
    /// This function is typically triggered by a user action and handles the collapsing and expanding
    /// of the navigator pane in a split view interface. It also notifies extensions of the change.
    @objc func toggleNavigatorPane() {
        guard let navigatorPane = splitViewController.splitViewItems.first else { return }

        NSAnimationContext.runAnimationGroup { _ in
            navigatorPane.animator().isCollapsed.toggle()
        }

        ExtensionsManager.shared.sendEvent(
            event: "didToggleNavigatorPane",
            parameters: [
                "opened": !navigatorPane.animator().isCollapsed
            ]
        )
    }

    /// Toggles the visibility of the inspector pane in the application's user interface.
    ///
    /// This function is typically triggered by a user action and handles the collapsing and expanding
    /// of the inspector pane in a split view interface. It also updates related preferences and
    /// notifies extensions of the change.
    @objc func toggleInspectorPane() {
        guard let inspectorPane = splitViewController.splitViewItems.last else { return }

        NSAnimationContext.runAnimationGroup { _ in
            inspectorPane.animator().isCollapsed.toggle()
        }

        prefs.preferences.general.keepInspectorSidebarOpen = !inspectorPane.isCollapsed

        ExtensionsManager.shared.sendEvent(
            event: "didToggleInspectorPane",
            parameters: [
                "opened": !inspectorPane.animator().isCollapsed
            ]
        )
    }
}

private extension NSToolbarItem.Identifier {
    /// The identifier for the navigator pane toggle button.
    static let toggleNavigator = NSToolbarItem.Identifier("ToggleNavigator")

    /// The identifier for the inspector pane toggle button.
    static let toggleInspector = NSToolbarItem.Identifier("ToggleInspector")

    /// The identifier for the item list tracking separator.
    static let itemListTrackingSeparator = NSToolbarItem.Identifier("ItemListTrackingSeparator")

    /// The identifier for the branch picker.
    static let branchPicker = NSToolbarItem.Identifier("BranchPicker")

    /// The identifier for the library popup.
    static let libraryPopup = NSToolbarItem.Identifier("LibraryPopup")

    /// The identifier for the run application button.
    static let runApplication = NSToolbarItem.Identifier("RunApplication")

    /// The identifier for the app information view.
    static let toolbarAppInformation = NSToolbarItem.Identifier("ToolbarAppInformation")
}
