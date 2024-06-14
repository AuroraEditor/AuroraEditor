//
//  Workflows.swift
//  Aurora Editor
//
//  Created by Nanashi Li on 2022/09/13.
//  Copyright © 2023 Aurora Company. All rights reserved.
//

import Foundation

/// GitHub Actions Workflow
struct Workflows: Codable {
    /// Total count
    let totalCount: Int

    /// Workflows
    let workflows: [Workflow]

    /// Coding keys
    enum CodingKeys: String, CodingKey {
        case totalCount = "total_count"
        case workflows
    }
}
