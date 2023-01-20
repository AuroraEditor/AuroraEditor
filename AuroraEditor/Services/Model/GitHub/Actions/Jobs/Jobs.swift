//
//  Jobs.swift
//  Aurora Editor
//
//  Created by Nanashi Li on 2022/09/13.
//

import Foundation

struct Jobs: Codable {
    let id: Int
    let runId: Int
    let runURL: String
    let runAttempt: Int
    let url: String
    let htmlURL: String
    let status: String
    let conclusion: String
    let startedAt: String
    let completedAt: String
    let name: String
    let steps: [JobSteps]
    let runnerName: String?
    let runnerGroupName: String?

    enum CodingKeys: String, CodingKey {
        case id
        case runId = "run_id"
        case runURL = "run_url"
        case runAttempt = "run_attempt"
        case url
        case htmlURL = "html_url"
        case status
        case conclusion
        case startedAt = "started_at"
        case completedAt = "completed_at"
        case name
        case steps
        case runnerName = "runner_name"
        case runnerGroupName = "runner_group_name"
    }
}
