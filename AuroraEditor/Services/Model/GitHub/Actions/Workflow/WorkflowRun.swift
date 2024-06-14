//
//  WorkflowRun.swift
//  Aurora Editor
//
//  Created by Nanashi Li on 2022/09/13.
//  Copyright © 2023 Aurora Company. All rights reserved.
//

import Foundation

/// GitHub Actions Workflow Run
struct WorkflowRun: Codable {
    /// Identifier
    let id: Int

    /// Name
    let name: String

    /// Node ID
    let nodeId: String

    /// Head Branch
    let headBranch: String

    /// Run Number
    let runNumber: Int

    /// Status
    let status: String

    /// Conclusion
    let conclusion: String

    /// Workflow ID
    let workflowId: Int

    /// URL
    let url: String

    /// HTML URL
    let htmlURL: String

    /// Created At
    let createdAt: String

    /// Updated At
    let updatedAt: String

    /// Head Commit
    let headCommit: WorkflowRunCommit

    /// Coding Keys
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case nodeId = "node_id"
        case headBranch = "head_branch"
        case runNumber = "run_number"
        case status
        case conclusion
        case workflowId = "workflow_id"
        case url
        case htmlURL = "html_url"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
        case headCommit = "head_commit"
    }
}

/// GitHub Actions Workflow Run Commit
struct WorkflowRunCommit: Codable {
    /// Identifier
    let id: String

    /// Tree ID
    let treeId: String

    /// Message
    let message: String

    /// Timestamp
    let timestamp: String

    /// Author
    let author: CommitAuthor

    enum CodingKeys: String, CodingKey {
        case id
        case treeId = "tree_id"
        case message
        case timestamp
        case author
    }
}

/// GitHub Actions Workflow Run Commit Author
struct CommitAuthor: Codable {
    /// Name
    let name: String

    /// Email
    let email: String
}
