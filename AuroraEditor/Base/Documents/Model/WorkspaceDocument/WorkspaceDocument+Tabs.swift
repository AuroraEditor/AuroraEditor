//
//  WorkspaceDocument+Tabs.swift
//  AuroraEditor
//
//  Created by TAY KAI QUAN on 8/8/22.
//  Copyright © 2022 Aurora Company. All rights reserved.
//

import Foundation

extension WorkspaceDocument {

    // MARK: Open Tabs

    /// Opens new tab
    /// - Parameter item: any item which can be represented as a tab
    func openTab(item: TabBarItemRepresentable) {
        do {
            updateNewlyOpenedTabs(item: item)
            if selectionState.selectedId != item.tabID {
                selectionState.selectedId = item.tabID
            }
            switch item.tabID {
            case .codeEditor:
                guard let file = item as? WorkspaceClient.FileItem else { return }
                try self.openFile(item: file)
            case .extensionInstallation:
                guard let plugin = item as? Plugin else { return }
                self.openExtension(item: plugin)
            case .webTab:
                guard let webTab = item as? WebTab else { return }
                self.openWebTab(item: webTab)
            }

        } catch let err {
            Log.error(err)
        }
    }

    /// Updates the opened tabs and temporary tab.
    /// - Parameter item: The item to use to update the tab state.
    private func updateNewlyOpenedTabs(item: TabBarItemRepresentable) {
        if !selectionState.openedTabs.contains(item.tabID) {
            // If this isn't opened then we do the temp tab functionality

            // But, if there is already a temporary tab, close it first
            if selectionState.temporaryTab != nil {
                if let index = selectionState.openedTabs.firstIndex(of: selectionState.temporaryTab!) {
                    closeTemporaryTab()
                    selectionState.openedTabs[index] = item.tabID
                } else {
                    selectionState.openedTabs.append(item.tabID)
                }
            } else {
                selectionState.openedTabs.append(item.tabID)
            }

            selectionState.previousTemporaryTab = selectionState.temporaryTab
            selectionState.temporaryTab = item.tabID
        }
    }

    private func openFile(item: WorkspaceClient.FileItem) throws {
        if !selectionState.openFileItems.contains(item) {
            selectionState.openFileItems.append(item)
        }
        let pathExtention = item.url.pathExtension
        let codeFile = try CodeFileDocument(
            for: item.url,
            withContentsOf: item.url,
            ofType: pathExtention
        )
        selectionState.openedCodeFiles[item] = codeFile
    }

    private func openExtension(item: Plugin) {
        if !selectionState.openedExtensions.contains(item) {
            selectionState.openedExtensions.append(item)
        }
    }

    private func openWebTab(item: WebTab) {
        // its not possible to have the same web tab opened multiple times, so no need to check
        selectionState.openedWebTabs.append(item)
    }

    // MARK: Close Tabs

    /// Closes single tab
    /// - Parameter id: tab bar item's identifier to be closed
    func closeTab(item id: TabBarItemID) {
        if id == selectionState.temporaryTab {
            selectionState.previousTemporaryTab = selectionState.temporaryTab
            selectionState.temporaryTab = nil
        }

        guard let idx = selectionState.openedTabs.firstIndex(of: id) else { return }
        let closedID = selectionState.openedTabs.remove(at: idx)
        guard closedID == id else { return }

        switch id {
        case .codeEditor:
            guard let item = selectionState.getItemByTab(id: id) as? WorkspaceClient.FileItem else { return }
            closeFileTab(item: item)
        case .extensionInstallation:
            guard let item = selectionState.getItemByTab(id: id) as? Plugin else { return }
            closeExtensionTab(item: item)
        case .webTab:
            guard let item = selectionState.getItemByTab(id: id) as? WebTab else { return }
            closeWebTab(item: item)
        }

        if selectionState.openedTabs.isEmpty {
            selectionState.selectedId = nil
        } else if selectionState.selectedId == closedID {
            // If the closed item is the selected one, then select another tab.
            if idx == 0 {
                selectionState.selectedId = selectionState.openedTabs.first
            } else {
                selectionState.selectedId = selectionState.openedTabs[idx - 1]
            }
        } else {
            // If the closed item is not the selected one, then do nothing.
        }
    }

    /// Closes collection of tab bar items
    /// - Parameter items: items to be closed
    func closeTabs<Items>(items: Items) where Items: Collection, Items.Element == TabBarItemID {
        // TODO: Could potentially be optimized
        for item in items {
            closeTab(item: item)
        }
    }

    /// Closes tabs according to predicator
    /// - Parameter predicate: predicator which returns whether tab should be closed based on its identifier
    func closeTab(where predicate: (TabBarItemID) -> Bool) {
        closeTabs(items: selectionState.openedTabs.filter(predicate))
    }

    /// Closes tabs after specified identifier
    /// - Parameter id: identifier after which tabs will be closed
    func closeTabs(after id: TabBarItemID) {
        guard let startIdx = selectionState.openFileItems.firstIndex(where: { $0.tabID == id }) else {
            assert(false, "Expected file item to be present in openFileItems")
            return
        }

        let range = selectionState.openedTabs[(startIdx+1)...]
        closeTabs(items: range)
    }

    /// Closes an open temporary tab, does not save the temporary tab's file.
    /// Removes the tab item from `openedCodeFiles`, `openedExtensions`, and `openFileItems`.
    private func closeTemporaryTab() {
        guard let id = selectionState.temporaryTab else { return }

        switch id {
        case .codeEditor:
            guard let item = selectionState.getItemByTab(id: id)
                    as? WorkspaceClient.FileItem else { return }
            selectionState.openedCodeFiles.removeValue(forKey: item)
        case .extensionInstallation:
            guard let item = selectionState.getItemByTab(id: id)
                    as? Plugin else { return }
            closeExtensionTab(item: item)
        case .webTab:
            guard let item = selectionState.getItemByTab(id: id)
                    as? WebTab else { return }
            closeWebTab(item: item)
        }

        guard let openFileItemIdx = selectionState
            .openFileItems
            .firstIndex(where: { $0.tabID == id }) else { return }
        selectionState.openFileItems.remove(at: openFileItemIdx)
    }

    /// Closes an open tab, save text files only.
    /// Removes the tab item from `openedCodeFiles`, `openedExtensions`, and `openFileItems`.
    private func closeFileTab(item: WorkspaceClient.FileItem) {
        let file = selectionState.openedCodeFiles.removeValue(forKey: item)
        if file?.typeOfFile != .image {
            file?.saveFileDocument()
        }

        guard let idx = selectionState.openFileItems.firstIndex(of: item) else { return }
        selectionState.openFileItems.remove(at: idx)
    }

    private func closeExtensionTab(item: Plugin) {
        guard let idx = selectionState.openedExtensions.firstIndex(of: item) else { return }
        selectionState.openedExtensions.remove(at: idx)
    }

    private func closeWebTab(item: WebTab) {
        guard let idx = selectionState.openedWebTabs.firstIndex(of: item) else { return }
        selectionState.openedWebTabs.remove(at: idx)
    }

    /// Makes the temporary tab permanent when a file save or edit happens.
    @objc func convertTemporaryTab() {
        if selectionState.selectedId == selectionState.temporaryTab &&
            selectionState.temporaryTab != nil {
            selectionState.previousTemporaryTab = selectionState.temporaryTab
            selectionState.temporaryTab = nil
        }
    }
}
