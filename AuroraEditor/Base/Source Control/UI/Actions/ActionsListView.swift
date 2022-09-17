//
//  ActionsListView.swift
//  AuroraEditor
//
//  Created by Nanashi Li on 2022/09/13.
//  Copyright © 2022 Aurora Company. All rights reserved.
//

import SwiftUI

struct ActionsListView: View {

    @ObservedObject
    private var actionsModel: GitHubActions

    @State
    private var actionSelection: Workflow.ID?

    init(workspace: WorkspaceDocument) {
        self.actionsModel = .init(workspace: workspace)
    }

    var body: some View {
        VStack(alignment: .leading) {
            List(selection: $actionSelection) {
                ForEach(actionsModel.workflows) { workflow in
                    Button {
                        actionsModel.workspace.openTab(item: workflow)
                    } label: {
                        WorkflowCellView(workflow: workflow)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.top, -5)
            .listStyle(.plain)
        }
        .onAppear {
            actionsModel.fetchWorkflows()
        }
    }
}

struct ActionsListView_Previews: PreviewProvider {
    static var previews: some View {
        ActionsListView(workspace: WorkspaceDocument())
    }
}
