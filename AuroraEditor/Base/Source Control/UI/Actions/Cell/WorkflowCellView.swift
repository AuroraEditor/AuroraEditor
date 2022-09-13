//
//  WorkflowCellView.swift
//  AuroraEditor
//
//  Created by Nanashi Li on 2022/09/13.
//  Copyright © 2022 Aurora Company. All rights reserved.
//

import SwiftUI

struct WorkflowCellView: View {

    @State
    var workflow: Workflow

    var body: some View {
        HStack {
            Image(systemName: "diamond")

            VStack(alignment: .leading) {
                Text(workflow.name)
                    .font(.system(size: 11, weight: .medium))

                Text(workflow.path)
                    .font(.system(size: 9))
                    .foregroundColor(.secondary)
            }
        }
        .padding(.horizontal, 10)
    }
}

struct WorkflowCellView_Previews: PreviewProvider {
    static var previews: some View {
        WorkflowCellView(workflow: Workflow(id: 0,
                                            node_id: "",
                                            name: "Nighlty Build",
                                            path: "./workflows/build.yml",
                                            state: "",
                                            created_at: "",
                                            updated_at: "",
                                            url: "",
                                            html_url: ""))
    }
}
