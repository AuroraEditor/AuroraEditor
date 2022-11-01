//
//  WindowDataStorage.swift
//  AuroraEditor
//
//  Created by TAY KAI QUAN on 30/10/22.
//  Copyright © 2022 Aurora Company. All rights reserved.
//

import SwiftUI

class AuroraDataStorage: ObservableObject {

    var windowController: AuroraEditorWindowController?

    init(windowController: AuroraEditorWindowController? = nil) {
        self.windowController = windowController
    }

    // NOTE: For the sake of clean code, I disable opening_brace so that the didSet commands
    // are visually apart from the variable.

    // swiftlint:disable:next swiftlint_file_disabling
    // swiftlint:disable opening_brace
    @Published
    var sortFoldersOnTop: Bool = true                               { didSet { update() } }
    @Published
    var showStashChangesSheet: Bool = false                         { didSet { update() } }
    @Published
    var showRenameBranchSheet: Bool = false                         { didSet { update() } }
    @Published
    var showAddRemoteView: Bool = false                             { didSet { update() } }
    @Published
    var showBranchCreationSheet: Bool = false                       { didSet { update() } }
    @Published
    var currentlySelectedBranch: String = ""                        { didSet { update() } }
    @Published
    var branchRevision: String = ""                                 { didSet { update() } }
    @Published
    var branchRevisionDescription: String = ""                      { didSet { update() } }
    @Published
    public var caretPos: CursorLocation = .init(line: 0, column: 0) { didSet { update() } }
    @Published
    var currentToken: Token?                                        { didSet { update() } }
    // swiftlint:enable opening_brace

    /// Function that updates the ``AuroraEditorWindowController`` and the ``WorkspaceDocument``.
    /// Views may reference this class via either of them, and therefore both need to be updated in order
    /// to make sure that the command is recieved by all listeners.
    func update() {
        windowController?.objectWillChange.send()
        windowController?.workspace.objectWillChange.send()
    }
}
