//
//  JobSteps.swift
//  AuroraEditor
//
//  Created by Nanashi Li on 2022/09/13.
//  Copyright © 2022 Aurora Company. All rights reserved.
//

import Foundation

struct JobSteps: Codable {
    let name: String
    let status: String
    let conclusion: String
    let number: Int
    let started_at: String
    let completed_at: String
}
