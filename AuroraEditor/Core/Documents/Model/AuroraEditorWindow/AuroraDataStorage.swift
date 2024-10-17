//
//  WindowDataStorage.swift
//  Aurora Editor
//
//  Created by TAY KAI QUAN on 30/10/22.
//  Copyright © 2023 Aurora Company. All rights reserved.
//

import SwiftUI
import Version_Control

/// A class that stores the data for the editor window.
@MainActor
class AuroraDataStorage: ObservableObject {
    /// The window controller that manages the window.
    var windowController: AuroraEditorWindowController?

    /// Creates a new instance of the data storage.
    /// 
    /// - Parameter windowController: The window controller that manages the window.
    init(windowController: AuroraEditorWindowController? = nil) {
        self.windowController = windowController
    }

    /// Sort folders on top
    @Published
    var sortFoldersOnTop: Bool = true {
        didSet { update() }
    }

    /// Show stash changes sheet
    @Published
    var showStashChangesSheet: Bool = false {
        didSet { update() }
    }

    /// Show rename branch sheet
    @Published
    var showRenameBranchSheet: Bool = false {
        didSet { update() }
    }

    /// Show add remote view
    @Published
    var showAddRemoteView: Bool = false {
        didSet { update() }
    }

    /// Show branch creation sheet
    @Published
    var showBranchCreationSheet: Bool = false {
        didSet { update() }
    }

    /// Show tag creation sheet
    @Published
    var showTagCreationSheet: Bool = false {
        didSet { update() }
    }

    /// Current selected branch
    @Published
    var currentlySelectedBranch: String = "" {
        didSet { update() }
    }

    /// Branch revision
    @Published
    var branchRevision: String = "" {
        didSet { update() }
    }

    /// Commit hash
    @Published
    var commitHash: String = "" {
        didSet { update() }
    }

    /// Branch revision description
    @Published
    var branchRevisionDescription: String = "" {
        didSet { update() }
    }

    @Published
    var currentBranch: GitBranch = GitBranch(name: "",
                                             type: .local,
                                             ref: "") {
        didSet { update() }
    }

    /// Caret position
    @Published
    @MainActor
    public var caretPos: CursorLocation = .init(line: 0, column: 0) {
        didSet {
            update()

            ExtensionsManager.shared.sendEvent(
                event: "didMoveCaret",
                parameters: [
                    "row": caretPos.line,
                    "col": caretPos.column
                ]
            )
        }
    }

    /// Bracket count
    @Published
    @MainActor
    public var bracketCount: BracketCount = .init(
        roundBracketCount: 0,
        curlyBracketCount: 0,
        squareBracketCount: 0,
        bracketHistory: []
    ) {
        didSet {
            update()

            ExtensionsManager.shared.sendEvent(
                event: "updateBracketCount",
                parameters: [
                    "roundBracketCount": bracketCount.roundBracketCount,
                    "curlyBracketCount": bracketCount.curlyBracketCount,
                    "squareBracketCount": bracketCount.squareBracketCount,
                    "bracketHistory": bracketCount.bracketHistory
                ]
            )
        }

    }

    /// Function that updates the ``AuroraEditorWindowController`` and the ``WorkspaceDocument``.
    /// Views may reference this class via either of them, and therefore both need to be updated in order
    /// to make sure that the command is recieved by all listeners.
    func update() {
        windowController?.objectWillChange.send()
        windowController?.workspace.objectWillChange.send()
    }
}
