//
//  JobSteps.swift
//  Aurora Editor
//
//  Created by Nanashi Li on 2022/09/13.
//  Copyright © 2023 Aurora Company. All rights reserved.
//

import Foundation

struct JobSteps: Codable {
    let name: String
    let status: String
    let conclusion: String
    let number: Int
    let startedAt: String
    let completedAt: String

    enum CodingKeys: String, CodingKey {
        case name
        case status
        case conclusion
        case number
        case startedAt = "started_at"
        case completedAt = "completed_at"
    }
}
