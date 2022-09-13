//
//  WorkflowRun.swift
//  AuroraEditor
//
//  Created by Nanashi Li on 2022/09/13.
//  Copyright © 2022 Aurora Company. All rights reserved.
//

import Foundation

struct WorkflowRun: Codable {
    let id: Int
    let name: String
    let node_id: String
    let head_branch: String
    let run_number: Int
    let status: String
    let conclusion: String
    let workflow_id: Int
    let url: String
    let html_url: String
    let created_at: String
    let updated_at: String
    let head_commit: WorkflowRunCommit
}

struct WorkflowRunCommit: Codable {
    let id: String
    let tree_id: String
    let message: String
    let timestamp: String
    let author: CommitAuthor

}

struct CommitAuthor: Codable {
    let name: String
    let email: String
}
