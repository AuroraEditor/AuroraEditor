//
//  NetworkingConstant.swift
//  AuroraEditor
//
//  Created by Nanashi Li on 2022/09/13.
//  Copyright © 2022 Aurora Company. All rights reserved.
//

import Foundation

// swiftlint:disable:next convenience_type
struct GithubNetworkingConstants {
    static var baseURL: String = "https://api.github.com/"

    // GitHub Actions

    // MARK: Workflows
    static func workflows(_ owner: String, _ repo: String) -> String {
        return "repos/\(owner)/\(repo)/actions/workflows"
    }

    static func workflow(_ owner: String,
                         _ repo: String,
                         workflowId: String) -> String {
        return "repos/\(owner)/\(repo)/actions/workflows/\(workflowId)"
    }

    static func workflowRuns(_ owner: String,
                             _ repo: String,
                             workflowId: String) -> String {
        return "repos/\(owner)/\(repo)/actions/workflows/\(workflowId)/runs"
    }

    // MARK: Workflow Runs
    static func reRunWorkflow(_ owner: String,
                              _ repo: String,
                              runId: String) -> String {
        return "repos/\(owner)/\(repo)/actions/runs/\(runId)/rerun"
    }

    static func cancelWorkflow(_ owner: String,
                               _ repo: String,
                               runId: String) -> String {
        return "repos/\(owner)/\(repo)/actions/runs/\(runId)/cancel"
    }

    // MARK: Workflow Jobs
    static func reRunJob(_ owner: String,
                         _ repo: String,
                         jobId: String) -> String {
        return "repos/\(owner)/\(repo)/actions/jobs/\(jobId)/rerun"
    }

    static func workflowJob(_ owner: String,
                            _ repo: String,
                            jobId: String) -> String {
        return "repos/\(owner)/\(repo)/actions/jobs/\(jobId)"
    }

    static func workflowJobs(_ owner: String,
                             _ repo: String,
                             runId: String) -> String {
        return "repos/\(owner)/\(repo)/actions/runs/\(runId)/jobs"
    }

    static func downloadWorkflowJobLog(_ owner: String,
                                       _ repo: String,
                                       jobId: String) -> String {
        return "repos/\(owner)/\(repo)/actions/jobs/\(jobId)/logs"
    }
}
