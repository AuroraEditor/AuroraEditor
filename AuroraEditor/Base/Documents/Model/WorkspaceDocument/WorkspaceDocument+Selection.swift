//
//  WorkspaceDocument+Selection.swift
//  AuroraEditor
//
//  Created by Pavel Kasila on 30.04.22.
//

import Foundation

struct WorkspaceSelectionState: Codable {
    var selectedId: TabBarItemID?
    var openedTabs: [TabBarItemID] = []
    var savedTabs: [TabBarItemStorage] = []
    var temporaryTab: TabBarItemID?
    var previousTemporaryTab: TabBarItemID?

    var selected: TabBarItemRepresentable? {
        guard let selectedId = selectedId else { return nil }
        return getItemByTab(id: selectedId)
    }

    var openFileItems: [FileSystemClient.FileItem] = []
    var openedCodeFiles: [FileSystemClient.FileItem: CodeFileDocument] = [:]

    var openedExtensions: [Plugin] = []

    var openedWebTabs: [WebTab] = []

    var openedProjectCommitHistory: [ProjectCommitHistory] = []

    var openedBranchCommitHistory: [BranchCommitHistory] = []

    enum CodingKeys: String, CodingKey {
        case selectedId,
             openedTabs,
             temporaryTab,
             openedExtensions,
             openedWebTabs,
             projectCommitHistory,
             branchCommitHistory
    }

    init() {
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        selectedId = try container.decode(TabBarItemID?.self, forKey: .selectedId)
        openedTabs = try container.decode([TabBarItemID].self, forKey: .openedTabs)
        temporaryTab = try container.decode(TabBarItemID?.self, forKey: .temporaryTab)
        openedExtensions = try container.decode([Plugin].self, forKey: .openedExtensions)
        openedWebTabs = try container.decode([WebTab].self, forKey: .openedWebTabs)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(selectedId, forKey: .selectedId)
        try container.encode(openedTabs, forKey: .openedTabs)
        try container.encode(temporaryTab, forKey: .temporaryTab)
        try container.encode(openedExtensions, forKey: .openedExtensions)
        try container.encode(openedWebTabs, forKey: .openedWebTabs)
    }

    /// Returns TabBarItemRepresentable by its identifier
    /// - Parameter id: tab bar item's identifier
    /// - Returns: item with passed identifier
    func getItemByTab(id: TabBarItemID) -> TabBarItemRepresentable? {
        switch id {
        case .codeEditor:
            return self.openFileItems.first { item in
                item.tabID == id
            }
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
        }
    }
}
