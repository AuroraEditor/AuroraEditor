//
//  Job.swift
//  Aurora Editor
//
//  Created by Nanashi Li on 2022/09/13.
//

import Foundation

struct Job: Codable {
    let totalCount: Int
    let jobs: [Jobs]

    enum CodingKeys: String, CodingKey {
        case totalCount = "total_count"
        case jobs
    }
}
