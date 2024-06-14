//
//  Jobs.swift
//  Aurora Editor
//
//  Created by Nanashi Li on 2022/09/13.
//  Copyright © 2023 Aurora Company. All rights reserved.
//

import Foundation

/// GitHub Actions Jobs
struct Jobs: Codable {
    /// Identifier
    let id: Int

    /// Run identifier
    let runId: Int

    /// Run URL
    let runURL: String

    /// Run attempt
    let runAttempt: Int

    /// URL
    let url: String

    /// HTML URL
    let htmlURL: String

    /// Status
    let status: String

    /// Conclusion
    let conclusion: String

    /// Started at
    let startedAt: String

    /// Completed at
    let completedAt: String

    /// Name
    let name: String

    /// Steps
    let steps: [JobSteps]

    /// Runner name
    let runnerName: String?

    /// Runner group name
    let runnerGroupName: String?

    /// Coding keys
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
