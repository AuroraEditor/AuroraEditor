//
//  ReRunJobSheetView.swift
//  AuroraEditor
//
//  Created by Nanashi Li on 2022/09/17.
//  Copyright © 2022 Aurora Company. All rights reserved.
//

import SwiftUI

struct ReRunJobSheetView: View {
    @Environment(\.dismiss)
    private var dismiss

    @ObservedObject
    var actions: GitHubActions

    @State
    private var enableDebugging: Bool = false

    @State var ghJobId: String = ""

    init(workspace: WorkspaceDocument, jobId: String) {
        self.actions = .init(workspace: workspace)

        // This @State will not update for a strange reason.
        self.ghJobId = jobId

        // We set the id on a @ObservedObject to bypass this issue.
        actions.jobId = jobId
    }

    var body: some View {
        VStack(alignment: .leading) {
            Text("Re-Run Single Job")

            Text("A new attempt of this workflow will be started, including **build** and dependents.")
                .font(.system(size: 11))
                .padding(.vertical, 1)

            HStack {
                Toggle(isOn: $enableDebugging) {
                    Text("Enable debug logging")
                }
                .toggleStyle(.checkbox)

                Spacer()

                Button {
                    dismiss()
                } label: {
                    Text("Cancel")
                        .foregroundColor(.primary)
                }

                Button {
                    actions.reRunWorkflowJobs(
                        jobId: actions.jobId,
                        enableDebugging: enableDebugging
                    )

                    dismiss()
                } label: {
                    Text("Re-Run Jobs")
                        .foregroundColor(.white)
                }
                .buttonStyle(.borderedProminent)
            }
            .padding(.top)
        }
        .padding()
    }
}
