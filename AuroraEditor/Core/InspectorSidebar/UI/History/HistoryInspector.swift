//
//  HistoryInspector.swift
//  Aurora Editor
//
//  Created by Nanashi Li on 2022/03/24.
//  Copyright © 2023 Aurora Company. All rights reserved.
//
import SwiftUI
import Version_Control

// This shows source control history, and is very 
// useful particularly if you are using git.
struct HistoryInspector: View {

    /// The model for the History Inspector
    @ObservedObject
    private var model: HistoryInspectorModel

    /// The preferences model
    @ObservedObject
    private var prefs: AppPreferencesModel = .shared

    /// The selected commit history
    @State
    var selectedCommitHistory: CommitHistory?

    /// Initialize with a workspace URL and a file URL
    ///
    /// - Parameter workspaceURL: the current workspace URL
    /// - Parameter fileURL: the current file URL
    /// 
    /// - Returns: a new HistoryInspector instance
    init(workspaceURL: URL, fileURL: String) {
        self.model = .init(workspaceURL: workspaceURL, fileURL: fileURL)
    }

    /// The body of the view
    var body: some View {
        VStack {
            if prefs.sourceControlActive() {
                switch model.state {
                case .loading:
                    VStack {
                        Text("Fetching History")
                            .font(.system(size: 16))
                            .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                case .success:
                    if model.commitHistory.isEmpty {
                        NoCommitHistoryView()
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                    } else {
                        List(selection: $selectedCommitHistory) {
                            ForEach(model.commitHistory) { commitHistory in
                                HistoryItem(commit: commitHistory, selection: $selectedCommitHistory)
                                    .tag(commitHistory)
                            }
                        }
                        .listStyle(.inset)
                    }
                case .error:
                    VStack {
                        Text("Failed To Get History")
                            .font(.system(size: 16))
                            .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
            } else {
                VStack(alignment: .center) {
                    Text("Source Control Disabled")
                        .font(.system(size: 16))
                        .foregroundColor(.secondary)

                    Text("Enable Source Control in settings")
                        .font(.system(size: 10))
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
        .frame(minWidth: 250, maxWidth: .infinity)
    }
}
