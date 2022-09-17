//
//  WorkflowJobsView.swift
//  AuroraEditor
//
//  Created by Nanashi Li on 2022/09/17.
//  Copyright © 2022 Aurora Company. All rights reserved.
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
    }

    var body: some View {
        VStack {
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
                    ReRunJobSheetView()
                }

                Button {
                    actionsModel.downloadWorkflowLogs(jobId: "")
                } label: {
                    Image(systemName: "square.and.arrow.down")
                }
                .buttonStyle(.plain)
                .help("Download log archive")
            }
            .padding(.horizontal)

            List(actionsModel.workflowJobs, id: \.number) { job in
                WorkflowJobCell(job: job)
            }
            .listStyle(.plain)
        }
        .onAppear {
            actionsModel.fetchWorkflowJobs(runId: runId)
        }
    }
}
