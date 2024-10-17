//
//  Aurora EditorAPI.swift
//  Aurora Editor
//
//  Created by Pavel Kasila on 5.04.22.
//  Copyright © 2023 Aurora Company. All rights reserved.
//

import Foundation
import AEExtensionKit

/// Aurora Editor API
final class AuroraEditorAPI: ExtensionAPI {
    /// Extension ID
    var extensionId: String

    /// Workspace
    var workspace: WorkspaceDocument

    /// Workspace URL
    nonisolated(unsafe) var workspaceURL: URL {
        return workspace.documentURL
    }

    /// Initialize Aurora Editor API
    /// 
    /// - Parameter extensionId: extension ID
    /// - Parameter workspace: workspace
    init(extensionId: String, workspace: WorkspaceDocument) {
        self.extensionId = extensionId
        self.workspace = workspace
    }
 }
