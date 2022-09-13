//
//  Jobs.swift
//  AuroraEditor
//
//  Created by Nanashi Li on 2022/09/13.
//  Copyright © 2022 Aurora Company. All rights reserved.
//

import Foundation

struct Jobs: Codable {
    let id: String
    let runId: String
    let run_url: String
    let url: String
    let html_url: String
    let status: String
    let conclusion: String
    let started_at: String
    let completed_at: String
    let name: String
    let steps: [JobSteps]
    let runner_name: String
    let runner_group_name: String
}
