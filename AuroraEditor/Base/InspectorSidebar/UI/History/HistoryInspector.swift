//
//  HistoryInspector.swift
//  AuroraEditor
//
//  Created by Nanashi Li on 2022/03/24.
//
import SwiftUI
import Version_Control

// This shows source control history, and is very 
// useful particularly if you are using git.
struct HistoryInspector: View {

    @ObservedObject
    private var model: HistoryInspectorModel

    @ObservedObject
    private var prefs: AppPreferencesModel = .shared

    @State
    var selectedCommitHistory: CommitHistory?

    /// Initialize with GitClient
    /// - Parameter gitClient: a GitClient
    init(workspaceURL: URL, fileURL: String) {
        self.model = .init(workspaceURL: workspaceURL, fileURL: fileURL)
    }

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
