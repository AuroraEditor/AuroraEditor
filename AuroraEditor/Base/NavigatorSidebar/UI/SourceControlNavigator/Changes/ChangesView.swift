//
//  ChangesView.swift
//  AuroraEditor
//
//  Created by Nanashi Li on 2022/05/20.
//

import SwiftUI

struct ChangesView: View {

    @ObservedObject
    var workspace: WorkspaceDocument

    @ObservedObject
    private var prefs: AppPreferencesModel = .shared

    var body: some View {
        VStack(alignment: .center) {
            if prefs.sourceControlActive() {
                switch workspace.workspaceClient?.model?.state {
                case .success:
                    if workspace.workspaceClient!.model!.changed.isEmpty {
                        Text("No Changes")
                            .font(.system(size: 16))
                            .foregroundColor(.secondary)
                    } else {
                        SourceControlView(workspace: workspace)
                    }
                case .loading:
                    VStack {
                        Text("Loading Changes")
                            .font(.system(size: 16))
                            .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                case .error:
                    VStack {
                        Text("Failed To Find Changes")
                            .font(.system(size: 16))
                            .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                case .none:
                    VStack {
                        Text("Failed To Find Changes")
                            .font(.system(size: 16))
                            .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
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
