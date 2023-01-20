//
//  Aurora EditorAPI.swift
//  Aurora Editor
//
//  Created by Pavel Kasila on 5.04.22.
//

import Foundation
import AEExtensionKit

final class AuroraEditorAPI: ExtensionAPI {
     var extensionId: String
     var workspace: WorkspaceDocument

     var workspaceURL: URL {
         workspace.fileURL!
     }

     init(extensionId: String, workspace: WorkspaceDocument) {
         self.extensionId = extensionId
         self.workspace = workspace
     }
 }
