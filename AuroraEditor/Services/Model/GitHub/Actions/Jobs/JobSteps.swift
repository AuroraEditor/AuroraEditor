//
//  JobSteps.swift
//  Aurora Editor
//
//  Created by Nanashi Li on 2022/09/13.
//  Copyright © 2023 Aurora Company. All rights reserved.
//

import Foundation

/// GitHub Actions Job Steps
struct JobSteps: Codable {
    /// Name
    let name: String

    /// Status
    let status: String

    /// Conclusion
    let conclusion: String

    /// Number
    let number: Int

    /// Started at
    let startedAt: String

    /// Completed at
    let completedAt: String

    /// Coding keys
    enum CodingKeys: String, CodingKey {
        case name
        case status
        case conclusion
        case number
        case startedAt = "started_at"
        case completedAt = "completed_at"
    }
}
