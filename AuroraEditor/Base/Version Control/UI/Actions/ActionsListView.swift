//
//  ActionsListView.swift
//  AuroraEditor
//
//  Created by Nanashi Li on 2022/09/13.
//  Copyright © 2022 Aurora Company. All rights reserved.
//

import SwiftUI

struct ActionsListView: View {

    var workspace: WorkspaceDocument

    @ObservedObject
    var actions: GitHubActions

    init(workspace: WorkspaceDocument) {
        self.actions = .init(workspace: workspace)
        self.workspace = workspace
    }

    var body: some View {
        VStack {
            WorkflowWrapperView(actionsModel: actions)

            // BUG: For some reason the list reints on selection when we add state management
            // not to sure what could be the cause
//            switch actions.state {
//            case .loading:
//                VStack {
//                    Text("Fetching Actions")
//                        .font(.system(size: 16))
//                        .foregroundColor(.secondary)
//                }
//                .frame(maxWidth: .infinity, maxHeight: .infinity)
//            case .success:
//                WorkflowWrapperView(workspace: workspace,
//                                    actionsModel: actions)
//            case .error:
//                VStack {
//                    Text("Failed to find any actions on your repo \(actions.repoOwner)\\\(actions.repo)")
//                        .font(.system(size: 16))
//                        .foregroundColor(.secondary)
//                }
//                .frame(maxWidth: .infinity, maxHeight: .infinity)
//            case .repoFailure:
//                VStack {
//                    Text("Failed to find git repo for the current project")
//                        .font(.system(size: 16))
//                        .foregroundColor(.secondary)
//                }
//                .frame(maxWidth: .infinity, maxHeight: .infinity)
//            }
        }
        .onAppear {
            actions.fetchWorkflows()
        }
    }
}
