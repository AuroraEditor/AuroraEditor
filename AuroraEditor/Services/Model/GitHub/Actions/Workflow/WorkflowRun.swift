//
//  WorkflowRun.swift
//  Aurora Editor
//
//  Created by Nanashi Li on 2022/09/13.
//  Copyright © 2023 Aurora Company. All rights reserved.
//

import Foundation

struct WorkflowRun: Codable {
    let id: Int
    let name: String
    let nodeId: String
    let headBranch: String
    let runNumber: Int
    let status: String
    let conclusion: String
    let workflowId: Int
    let url: String
    let htmlURL: String
    let createdAt: String
    let updatedAt: String
    let headCommit: WorkflowRunCommit

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

struct WorkflowRunCommit: Codable {
    let id: String
    let treeId: String
    let message: String
    let timestamp: String
    let author: CommitAuthor

    enum CodingKeys: String, CodingKey {
        case id
        case treeId = "tree_id"
        case message
        case timestamp
        case author
    }
}

struct CommitAuthor: Codable {
    let name: String
    let email: String
}
