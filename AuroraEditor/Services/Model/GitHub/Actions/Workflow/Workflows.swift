//
//  Workflows.swift
//  Aurora Editor
//
//  Created by Nanashi Li on 2022/09/13.
//

import Foundation

struct Workflows: Codable {
    let totalCount: Int
    let workflows: [Workflow]

    enum CodingKeys: String, CodingKey {
        case totalCount = "total_count"
        case workflows
    }
}
