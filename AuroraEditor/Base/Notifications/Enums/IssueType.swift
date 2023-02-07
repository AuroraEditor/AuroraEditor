//
//  IssueType.swift
//  Aurora Editor
//
//  Created by Nanashi Li on 05/02/2023.
//  Copyright © 2023 Aurora Company. All rights reserved.
//

import Foundation

enum IssueType: String {
    case build = "Build"
    case optimization = "Optimization"
    case analyze = "Analyze"
    case run = "Run"
    case leak = "Leak"
    case remark = "Remark"
    case test = "Test"
    case project = "Project"
    case deprecation = "Deprication"
}
