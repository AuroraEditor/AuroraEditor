//
//  Job.swift
//  Aurora Editor
//
//  Created by Nanashi Li on 2022/09/13.
//  Copyright © 2023 Aurora Company. All rights reserved.
//

import Foundation

/// GitHub Actions Job
struct Job: Codable {
    /// Total count
    let totalCount: Int

    /// Jobs
    let jobs: [Jobs]

    /// Coding keys
    enum CodingKeys: String, CodingKey {
        /// Total count
        case totalCount = "total_count"

        /// Jobs
        case jobs
    }
}
