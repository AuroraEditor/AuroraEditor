//
//  WorkflowRunsView.swift
//  Aurora Editor
//
//  Created by Nanashi Li on 2022/09/13.
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
        VStack {
            switch actionsModel.workflowRunState {
            case .loading:
                VStack {
                    Text("Fetching Workflow Runs....")
                        .font(.system(size: 16))
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            case .success:
                NavigationView {
                    VStack {
                        Divider()
                            .padding()
                        List(actionsModel.workflowRuns, id: \.id) { run in
                            NavigationLink {
                                WorkflowJobsView(workspace: actionsModel.workspace,
                                                 runId: String(run.id),
                                                 jobName: run.name)
                            } label: {
                                WorkflowRunCell(workflowRun: run)
                            }
                        }
                        .frame(minWidth: 450)
                        .navigationTitle("Workflow Runs")
                        Divider()
                            .padding()
                    }

                    VStack {
                        Text("Select A Run To View It's Jobs")
                            .font(.system(size: 16))
                            .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
            case .error:
                VStack {
                    Text("Failed To Fetch Workflow Runs.")
                        .font(.system(size: 16))
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            case .empty:
                VStack {
                    Text("Nothing But An Empty Void...")
                        .font(.system(size: 16))
                        .foregroundColor(.secondary)

                    Text("Try again later, it seems like at the moment GitHub is not returning anything.")
                        .multilineTextAlignment(.center)
                        .font(.system(size: 11))
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
        .onAppear {
            actionsModel.fetchWorkflowRuns(workflowId: workflowId)
        }
    }
}
