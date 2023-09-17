//
//  IssueType.swift
//  Aurora Editor
//
//  Created by Nanashi Li on 16/09/2023.
//  Copyright © 2023 Aurora Company. All rights reserved.
//

/// An enumeration representing different types of issues that can occur in a software project.
enum IssueType: String {
    /// A build-related issue.
    case build = "Build"

    /// An optimization-related issue.
    case optimization = "Optimization"

    /// An analysis-related issue.
    case analyze = "Analyze"

    /// A run-time issue.
    case run = "Run"

    /// A memory leak-related issue.
    case leak = "Leak"

    /// A remark or comment-related issue.
    case remark = "Remark"

    /// A testing-related issue.
    case test = "Test"

    /// A project-specific issue.
    case project = "Project"

    /// A deprecation-related issue.
    case deprecation = "Deprecation"
}
