//
//  HistoryInspectorModel.swift
//  Aurora Editor
//
//  Created by Nanashi Li on 2022/04/18.
//  Copyright © 2023 Aurora Company. All rights reserved.
//

import Foundation
@preconcurrency import Version_Control

/// The model for the History Inspector
public final class HistoryInspectorModel: ObservableObject {

    /// The state of the current History Inspector View
    enum State {
        case loading, error, success
    }

    /// The current state of the History Inspector
    @Published
    var state: State = .loading

    private(set) var workspace: URL

    /// The base URL of the workspace
    private(set) var fileURL: String

    /// The selected branch from the GitClient
    @Published
    public var commitHistory: [Commit] = []

    /// Initialize with a GitClient
    /// 
    /// - Parameter workspaceURL: the current workspace URL
    /// - Parameter fileURL: the current file URL
    ///
    /// - Returns: a new HistoryInspectorModel instance
    init(workspace: URL, fileURL: String) {
        self.workspace = workspace
        self.fileURL = fileURL

        DispatchQueue.global(qos: .background).async {
            do {
                let commitHistory = try GitLog().getCommits(directoryURL: workspace,
                                                            fileURL: fileURL,
                                                            revisionRange: nil,
                                                            limit: 40,
                                                            skip: 0,
                                                            additionalArgs: [])
                DispatchQueue.main.async {
                    self.commitHistory = commitHistory
                    self.state = .success
                }
            } catch {
                DispatchQueue.main.async {
                    self.commitHistory = []
                    self.state = .error
                }
            }
        }
    }
}
