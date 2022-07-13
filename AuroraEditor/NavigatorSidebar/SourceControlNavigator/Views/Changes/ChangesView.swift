//
//  ChangesView.swift
//  AuroraEditor
//
//  Created by Nanashi Li on 2022/05/20.
//

import SwiftUI
import AuroraEditorUI
import Git
import AppPreferences

struct ChangesView: View {

    @ObservedObject
    var model: SourceControlModel

    @ObservedObject
    private var prefs: AppPreferencesModel = .shared

    @State
    var selectedFile: ChangedFile.ID?

    /// Initialize with GitClient
    /// - Parameter gitClient: a GitClient
    init(workspaceURL: URL) {
        self.model = .init(workspaceURL: workspaceURL)
    }

    var body: some View {
        VStack(alignment: .center) {
            if prefs.sourceControlActive() {
                if model.changed.isEmpty {
                    Text("No Changes")
                        .font(.system(size: 16))
                        .foregroundColor(.secondary)
                } else {
                    List(selection: $selectedFile) {
                        Section("Local Changes") {
                            ForEach(model.changed) { file in
                                ChangedFileItemView(changedFile: file,
                                                    selection: $selectedFile)
                                .contextMenu {
                                    Group {
                                        Button("View in Finder") {
                                            file.showInFinder(workspaceURL: model.workspaceURL)
                                        }
                                        Button("Reveal in Project Navigator") {}
                                            .disabled(true) // TODO: Implementation Needed
                                        Divider()
                                    }
                                    Group {
                                        Button("Open in New Tab") {}
                                            .disabled(true) // TODO: Implementation Needed
                                        Button("Open in New Window") {}
                                            .disabled(true) // TODO: Implementation Needed
                                        Button("Open with External Editor") {}
                                            .disabled(true) // TODO: Implementation Needed
                                    }
                                    Group {
                                        Divider()
                                        Button("Commit \(file.fileName)...") {}
                                            .disabled(true) // TODO: Implementation Needed
                                        Divider()
                                        Button("Discard Changes in \(file.fileName)...") {
                                            model.discardFileChanges(file: file)
                                        }
                                        Divider()
                                    }
                                    Group {
                                        Button("Add \(file.fileName)") {}
                                            .disabled(true) // TODO: Implementation Needed
                                        Button("Mark \(file.fileName) as Resolved") {}
                                            .disabled(true) // TODO: Implementation Needed
                                    }
                                }
                            }
                        }
                        .foregroundColor(.secondary)
                    }
                    .listStyle(.sidebar)
                }
            } else {
                VStack {
                    Text("Source Control Disabled")
                        .font(.system(size: 16))
                        .foregroundColor(.secondary)

                    Text("Enable Source Control in settings")
                        .font(.system(size: 10))
                }
            }
        }
        .frame(maxHeight: .infinity)
    }
}
