//
//  WorkflowJobsView.swift
//  Aurora Editor
//
//  Created by Nanashi Li on 2022/09/17.
//

import SwiftUI

struct WorkflowJobsView: View {
    @ObservedObject
    private var actionsModel: GitHubActions

    @State
    private var reRunJobs: Bool = false

    @State
    private var runId: String

    @State
    private var jobName: String

    init(workspace: WorkspaceDocument,
         runId: String,
         jobName: String) {
        self.actionsModel = .init(workspace: workspace)
        self.runId = runId
        self.jobName = jobName
        actionsModel.fetchWorkflowJobs(runId: runId)
    }

    var body: some View {
        VStack {

        }
        switch actionsModel.jobsState {
        case .loading:
            VStack {
                Text("Fetching Run Jobs....")
                    .font(.system(size: 16))
                    .foregroundColor(.secondary)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        case .success:
            VStack {
                Divider()
                    .padding()
                HStack(spacing: 15) {
                    Text(jobName)
                        .font(.system(size: 14, weight: .bold))

                    Spacer()

                    Button {
                        reRunJobs.toggle()
                    } label: {
                        Image(systemName: "arrow.clockwise")
                    }
                    .buttonStyle(.plain)
                    .help("Re-run this job")
                    .sheet(isPresented: $reRunJobs) {
                        debug("Currently selected job id: \(actionsModel.jobId)")
                        ReRunJobSheetView(workspace: actionsModel.workspace,
                                          jobId: actionsModel.jobId)
                    }

                    // TODO: Find a way to show it for each job
                    Button {
                        actionsModel.downloadWorkflowLogs(jobId: actionsModel.jobId)
                    } label: {
                        Image(systemName: "square.and.arrow.down")
                    }
                    .buttonStyle(.plain)
                    .help("Download log archive")
                    .disabled(true)
                }
                .padding(.horizontal)

                List(actionsModel.workflowJob, id: \.id) { job in
                    ForEach(job.steps, id: \.number) { step in
                        WorkflowJobCell(job: step)
                    }
                }
                .listStyle(.plain)
                Divider()
                    .padding()
            }
        case .empty:
            VStack {
                Text("Hmmm... Seems Very Lonely Here, No Jobs Was Done It Looks Like.")
                    .font(.system(size: 16))
                    .foregroundColor(.secondary)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        case .error:
            VStack {
                Text("Failed To Find Any Jobs For This Run.")
                    .font(.system(size: 16))
                    .foregroundColor(.secondary)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }
}
