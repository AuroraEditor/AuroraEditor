//
//  WorkflowRuns.swift
//  Aurora Editor
//
//  Created by Nanashi Li on 2022/09/13.
//

import Foundation

struct WorkflowRuns: Codable {
    let totalCount: Int
    let workflowRuns: [WorkflowRun]?

    enum CodingKeys: String, CodingKey {
        case totalCount = "total_count"
        case workflowRuns = "workflow_runs"
    }
}
