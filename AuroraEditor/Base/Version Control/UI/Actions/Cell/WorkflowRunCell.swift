//
//  WorkflowRunCell.swift
//  AuroraEditor
//
//  Created by Nanashi Li on 2022/09/13.
//  Copyright © 2022 Aurora Company. All rights reserved.
//

import SwiftUI
import Version_Control

struct WorkflowRunCell: View {

    @State
    var workflowRun: WorkflowRun

    var body: some View {
        HStack {
            switch workflowRun.conclusion {
            case "in_progress":
                Image(systemName: "hourglass.circle")
                    .symbolRenderingMode(.multicolor)
            case "success":
                Image(systemName: "checkmark.diamond.fill")
                    .symbolRenderingMode(.multicolor)
            case "timed_out":
                Image(systemName: "exclamationmark.arrow.circlepath")
                    .symbolRenderingMode(.hierarchical)
            case "failure":
                Image(systemName: "xmark.diamond.fill")
                    .symbolRenderingMode(.multicolor)
            case "queued":
                Image(systemName: "timer.circle")
                    .symbolRenderingMode(.hierarchical)
            case "cancelled":
                Image(systemName: "xmark.diamond")
                    .symbolRenderingMode(.hierarchical)
            default:
                Image(systemName: "diamond")
            }

            Text(getCommitName())
                .font(.system(size: 12))

            Text(workflowRun.name)
                .font(.system(size: 11))
                .foregroundColor(.secondary)
        }
        .padding(.horizontal, 10)
    }

    private func getCommitName() -> String {
        return workflowRun.headCommit.message.split(separator: "\n")[0].description
    }
}
