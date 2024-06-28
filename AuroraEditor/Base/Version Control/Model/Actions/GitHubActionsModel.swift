//
//  GitHubActionsModel.swift
//  Aurora Editor
//
//  Created by Nanashi Li on 2022/09/13.
//  Copyright © 2023 Aurora Company. All rights reserved.
//

import Foundation
import Version_Control
import OSLog

@available(*, deprecated, renamed: "VersionControl", message: "This will be deprecated in favor of the new VersionControl Remote SDK APIs.")
/// Github actions model
class GitHubActions: ObservableObject {

    /// State
    enum State {

        /// Loading
        case loading

        /// Error
        case error

        /// Success
        case success

        /// Repistory failure
        case repoFailure
    }

    /// Workflow Run State
    enum WorkflowRunState {

        /// Loading
        case loading

        /// Error
        case error

        /// Success
        case success

        /// Empty
        case empty
    }

    /// Jobs State
    enum JobsState {

        /// Loading
        case loading

        /// Error
        case error

        /// Success
        case success

        /// Empty
        case empty
    }

    /// State
    @Published
    var state: State = .loading

    /// Workflow Run State
    @Published
    var workflowRunState: WorkflowRunState = .loading

    /// Jobs Run State
    @Published
    var jobsState: JobsState = .loading

    /// Workspace document
    let workspace: WorkspaceDocument

    /// Workflows
    @Published
    var workflows: [Workflow] = []

    /// Workflow Runs
    @Published
    var workflowRuns: [WorkflowRun] = []

    /// Workflow Jobs
    @Published
    var workflowJobs: [JobSteps] = []

    /// Workflow Job
    @Published
    var workflowJob: [Jobs] = []

    /// Repo Owner
    @Published
    var repoOwner: String = ""

    /// Repo
    @Published
    var repo: String = ""

    /// Job Id
    @Published
    var jobId: String = ""

    /// Logger
    let logger = Logger(subsystem: "com.auroraeditor.vcs", category: "GitHub Actions")

    /// Initialize Github Actions
    /// 
    /// - Parameter workspace: Workspace Document
    /// 
    /// - Returns: Github Actions
    init(workspace: WorkspaceDocument) {
        self.workspace = workspace

        getRepoInformation()
    }

    /// Fetch workflows
    func fetchWorkflows() {
        AuroraNetworking().request(baseURL: GithubNetworkingConstants.baseURL,
                                   path: GithubNetworkingConstants.workflows(repoOwner,
                                                                      repo),
                                   method: .GET,
                                   parameters: nil,
                                   completionHandler: { result in
            switch result {
            case .success(let data):
                let decoder = JSONDecoder()
                guard let workflows = try? decoder.decode(Workflows.self, from: data) else {
                    self.logger.debug(
                        "Error: Unable to decode \(String(data: data, encoding: .utf8) ?? "")"
                    )
                    DispatchQueue.main.async {
                        self.state = .error
                    }
                    return
                }
                DispatchQueue.main.async {
                    self.state = .success
                    self.workflows = workflows.workflows.sorted()
                    self.objectWillChange.send()
                }
            case .failure(let error):
                DispatchQueue.main.async {
                    self.state = .error
                }
                self.logger.fault("\(error)")
            }
        })
    }

    /// Fetch workflow runs
    /// 
    /// - Parameter workflowId: Workflow ID
    func fetchWorkflowRuns(workflowId: String) {
        DispatchQueue.main.async {
            self.workflowRunState = .loading
            self.objectWillChange.send()
        }
        AuroraNetworking().request(baseURL: GithubNetworkingConstants.baseURL,
                                   path: GithubNetworkingConstants.workflowRuns(repoOwner,
                                                                         repo,
                                                                         workflowId: workflowId),
                                   method: .GET,
                                   parameters: nil,
                                   completionHandler: { result in
            switch result {
            case .success(let data):
                do {
                    let decoder = JSONDecoder()
                    let workflowRuns = try decoder.decode(WorkflowRuns.self, from: data)
                    DispatchQueue.main.async {
                        if workflowRuns.workflowRuns?.isEmpty ?? true {
                            self.workflowRunState = .empty
                            return
                        }

                        self.workflowRuns = workflowRuns.workflowRuns ?? []
                        self.workflowRunState = .success
                    }
                } catch {
                    DispatchQueue.main.async {
                        self.workflowRunState = .error
                    }
                    self.logger.debug(
                        "Error: \(error), \(String(data: data, encoding: .utf8) ?? "")"
                    )
                }
            case .failure(let error):
                DispatchQueue.main.async {
                    self.workflowRunState = .error
                }
                self.logger.fault("\(error)")
            }

        })
    }

    /// Fetch workflow jobs
    /// 
    /// - Parameter runId: Run ID
    func fetchWorkflowJobs(runId: String) {
        DispatchQueue.main.async {
            self.jobsState = .loading
        }
        AuroraNetworking().request(baseURL: GithubNetworkingConstants.baseURL,
                                   path: GithubNetworkingConstants.workflowJobs(repoOwner,
                                                                         repo,
                                                                         runId: runId),
                                   method: .GET,
                                   parameters: nil,
                                   completionHandler: { result in
            switch result {
            case .success(let data):
                do {
                    let decoder = JSONDecoder()
                    let jobs = try decoder.decode(Job.self, from: data)
                    DispatchQueue.main.async {
                        self.workflowJob = jobs.jobs
                        self.jobId = String(jobs.jobs.first?.id ?? 0)

                        for job in self.workflowJob {
                            if job.steps.isEmpty {
                                self.jobsState = .empty
                                return
                            }

                            self.workflowJobs = job.steps
                            self.jobsState = .success
                        }
                        self.objectWillChange.send()
                    }
                } catch {
                    DispatchQueue.main.async {
                        self.jobsState = .error
                    }
                    self.logger.debug(
                        "Error: \(error), \(String(data: data, encoding: .utf8) ?? "")"
                    )
                }
            case .failure(let error):
                DispatchQueue.main.async {
                    self.jobsState = .error
                }
                self.logger.fault("\(error)")
            }
        })
    }

    /// Re-run workflow jobs
    /// 
    /// - Parameter jobId: Job ID
    /// - Parameter enableDebugging: Enable Debugging
    /// - Parameter completion: Completion
    func reRunWorkflowJobs(jobId: String,
                           enableDebugging: Bool,
                           completion: @escaping (Result<String, Error>) -> Void) {
        guard !jobId.isEmpty else {
            self.logger.fault("No job id provided")
            return
        }

        let parameter: [String: Bool] = [
            "enable_debug_logging": enableDebugging
        ]

        AuroraNetworking().request(baseURL: GithubNetworkingConstants.baseURL,
                                   path: GithubNetworkingConstants.reRunJob(repoOwner,
                                                                     repo,
                                                                     jobId: jobId),
                                   method: .POST,
                                   parameters: parameter,
                                   completionHandler: { result in
            switch result {
            case .success:
                self.logger.debug("Succeffully Re-Run job: \(jobId)")
                completion(.success("Succeffully Re-Run job: \(jobId)"))
            case .failure(let error):
                self.logger.fault("\(error)")
                completion(.failure(error))
            }
        })
    }

    /// Download workflow logs
    /// 
    /// - Parameter jobId: Job ID
    func downloadWorkflowLogs(jobId: String) {
        AuroraNetworking().request(baseURL: GithubNetworkingConstants.baseURL,
                                   path: GithubNetworkingConstants.reRunJob(repoOwner,
                                                                     repo,
                                                                     jobId: jobId),
                                   method: .POST,
                                   parameters: nil,
                                   completionHandler: { result in
            switch result {
            case .success:
                self.logger.debug("Succeffully Downloaded Workflow Logs for: \(jobId)")
            case .failure(let error):
                self.logger.fault("\(error)")
            }
        })
    }

    /// Get repo information
    func getRepoInformation() {
        do {
            let remote = try Remote().getRemoteURL(
                directoryURL: workspace.workspaceURL(),
                name: "origin"
            )
            let remoteURL = URL(string: remote!)

            // As caution we check if the origin contains git@ so we can fetch the repo
            // info in one of two ways.
            if remote?.contains("git@") ?? false {
                // git@github.com:AuroraEditor/AuroraEditor.git
                let splitGit = remote?.split(separator: ":")
                let splitRepoDetails = splitGit?[1].split(separator: "/")

                repoOwner = splitRepoDetails?[0].description ?? ""
                repo = splitRepoDetails?[1].description.replacingOccurrences(of: ".git", with: "") ?? ""
            } else {
                let remoteSplit = remoteURL?.pathComponents
                repoOwner = remoteSplit?[1] ?? ""

                let repoValue = remoteSplit?[2] ?? ""
                repo = repoValue.replacingOccurrences(of: ".git", with: "")
            }
            self.objectWillChange.send()
        } catch {
            self.logger.fault("Failed to get project remote URL.")
            DispatchQueue.main.async {
                self.state = .repoFailure
                self.objectWillChange.send()
            }
        }
    }
}
