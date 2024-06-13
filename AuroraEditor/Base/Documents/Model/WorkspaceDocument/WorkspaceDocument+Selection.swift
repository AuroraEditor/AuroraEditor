//
//  WorkspaceDocument+Selection.swift
//  Aurora Editor
//
//  Created by Pavel Kasila on 30.04.22.
//  Copyright © 2023 Aurora Company. All rights reserved.
//

import Foundation
import Version_Control

/// A struct that represents the workspace selection state.
struct WorkspaceSelectionState: Codable {
    /// The selected tab bar item identifier
    var selectedId: TabBarItemID?

    /// The opened tab bar item identifiers
    var openedTabs: [TabBarItemID] = []

    /// The saved tabs
    var savedTabs: [TabBarItemStorage] = []

    /// The flattened saved tabs
    var flattenedSavedTabs: [TabBarItemStorage] {
        var flat = [TabBarItemStorage]()

        for tab in savedTabs {
            flat.append(tab)
            flat.append(contentsOf: tab.flattenedChildren)
        }

        return flat
    }

    /// The temporary tab bar item identifier
    var temporaryTab: TabBarItemID?

    /// The previous temporary tab bar item identifier
    var previousTemporaryTab: TabBarItemID?

    /// The workspace document
    var workspace: WorkspaceDocument?

    /// The selected tab bar item
    var selected: TabBarItemRepresentable? {
        guard let selectedId = selectedId else { return nil }
        return getItemByTab(id: selectedId)
    }

    /// The opened file items
    var openFileItems: [FileSystemClient.FileItem] = []

    /// The opened code files
    var openedCodeFiles: [FileSystemClient.FileItem: CodeFileDocument] = [:]

    /// The opened extensions
    var openedExtensions: [Plugin] = []

    /// The opened web tabs
    var openedWebTabs: [WebTab] = []

    /// The opened project commit history
    var openedProjectCommitHistory: [ProjectCommitHistory] = []

    /// The opened branch commit history
    var openedBranchCommitHistory: [BranchCommitHistory] = []

    /// The opened actions workflow
    var openedActionsWorkflow: [Workflow] = []

    /// The opened custom extension views
    var openedCustomExtensionViews: [ExtensionCustomViewModel] = []

    /// The opened custom extension views
    enum CodingKeys: String, CodingKey {
        case selectedId,
             openedTabs,
             temporaryTab,
             openedExtensions,
             openedWebTabs,
             projectCommitHistory,
             branchCommitHistory,
             openedExtensionViews
    }

    /// Initializes the workspace selection state.
    init() {
    }

    /// Initializes the workspace selection state with the specified decoder.
    /// 
    /// - Parameter decoder: The decoder to use.
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        selectedId = try container.decode(TabBarItemID?.self, forKey: .selectedId)
        openedTabs = try container.decode([TabBarItemID].self, forKey: .openedTabs)
        temporaryTab = try container.decode(TabBarItemID?.self, forKey: .temporaryTab)
        openedExtensions = try container.decode([Plugin].self, forKey: .openedExtensions)
        openedWebTabs = try container.decode([WebTab].self, forKey: .openedWebTabs)
        openedCustomExtensionViews = try container.decode(
            [ExtensionCustomViewModel].self,
            forKey: .openedExtensionViews
        )
    }

    /// Encodes the workspace selection state using the specified encoder.
    ///     
    /// - Parameter encoder: The encoder to use.
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(selectedId, forKey: .selectedId)
        try container.encode(openedTabs, forKey: .openedTabs)
        try container.encode(temporaryTab, forKey: .temporaryTab)
        try container.encode(openedExtensions, forKey: .openedExtensions)
        try container.encode(openedWebTabs, forKey: .openedWebTabs)
        try container.encode(openedCustomExtensionViews, forKey: .openedExtensionViews)
    }

    /// Returns TabBarItemRepresentable by its identifier
    /// 
    /// - Parameter id: tab bar item's identifier
    /// 
    /// - Returns: item with passed identifier
    func getItemByTab(id: TabBarItemID) -> TabBarItemRepresentable? {
        switch id {
        case .codeEditor:
            let path = id.id.replacingOccurrences(of: "codeEditor_", with: "")
            // get it from the open file items, else fallback to the whole index
            if let fileItem = self.openFileItems.first(where: { $0.tabID == id }) {
                return fileItem
            }
            return try? workspace?.fileSystemClient?.getFileItem(path)
        case .extensionInstallation:
            return self.openedExtensions.first { item in
                item.tabID == id
            }
        case .webTab:
            return self.openedWebTabs.first { item in
                item.tabID == id
            }
        case .projectHistory:
            return self.openedProjectCommitHistory.first { item in
                item.tabID == id
            }
        case .branchHistory:
            return self.openedBranchCommitHistory.first { item in
                item.tabID == id
            }
        case .actionsWorkflow:
            return self.openedActionsWorkflow.first { item in
                item.tabID == id
            }
        case .extensionCustomView:
            return self.openedCustomExtensionViews.first { item in
                item.tabID == id
            }
        }
    }
}
