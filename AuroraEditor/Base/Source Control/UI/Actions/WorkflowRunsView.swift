//
//  WorkflowRunsView.swift
//  AuroraEditor
//
//  Created by Nanashi Li on 2022/09/13.
//  Copyright © 2022 Aurora Company. All rights reserved.
//

import SwiftUI

struct WorkflowRunsView: View {

    @ObservedObject
    private var actionsModel: GitHubActions

    @State
    private var workflowId: String

    init(workspace: WorkspaceDocument, workflowId: String) {
        self.actionsModel = .init(workspace: workspace)
        self.workflowId = workflowId
    }

    var body: some View {
        NavigationView {
            VStack {
                List(actionsModel.workflowRuns, id: \.id) { run in
                    NavigationLink {
                        Text(run.name)
                    } label: {
                        WorkflowRunCell(workflowRun: run)
                    }
                }
                .frame(minWidth: 450)
            }
        }
        .onAppear {
            actionsModel.fetchWorkflowRuns(workflowId: workflowId)
        }
    }
}
