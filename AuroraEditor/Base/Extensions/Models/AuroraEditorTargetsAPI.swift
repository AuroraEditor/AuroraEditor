//
//  AuroraEditorTargetsAPI.swift
//  AuroraEditor
//
//  Created by Pavel Kasila on 5.04.22.
//

import Foundation

final class AuroraEditorTargetsAPI: TargetsAPI {

    var workspace: WorkspaceDocument

    init(_ workspace: WorkspaceDocument) {
        self.workspace = workspace
    }

    func add(target: Target) {
        self.workspace.target(didAdd: target)
    }

    func delete(target: Target) {
        self.workspace.target(didRemove: target)
    }

    func clear() {
        self.workspace.targetDidClear()
    }
}
