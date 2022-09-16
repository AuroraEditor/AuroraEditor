//
//  GitHubActionsModel.swift
//  AuroraEditor
//
//  Created by Nanashi Li on 2022/09/13.
//  Copyright © 2022 Aurora Company. All rights reserved.
//

import Foundation

class GitHubActions: ObservableObject {

    let workspace: WorkspaceDocument

    @Published
    var workflows: [Workflow] = []

    @Published
    var workflowRuns: [WorkflowRun] = []

    @Published
    private var repoOwner: String = ""

    @Published
    private var repo: String = ""

    init(workspace: WorkspaceDocument) {
        self.workspace = workspace

        getRepoInformation()
    }

    func fetchWorkflows() {
        AuroraNetworking().request(path: NetworkingConstant.workflows(repoOwner,
                                                                      repo),
                                   method: .GET,
                                   parameters: nil,
                                   completionHandler: { result in
            switch result {
            case .success(let data):
                let decoder = JSONDecoder()
                guard let workflows = try? decoder.decode(Workflows.self, from: data) else {
                    return
                }
                DispatchQueue.main.async {
                    self.workflows = workflows.workflows
                }
            case .failure(let error):
                Log.error(error)
            }

        })
    }

    func fetchWorkflowRuns(workflowId: String) {
        AuroraNetworking().request(path: NetworkingConstant.workflowRuns(repoOwner,
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
                        self.workflowRuns = workflowRuns.workflow_runs
                    }
                } catch {
                    Log.debug("Error: \(error)")
                }
            case .failure(let error):
                Log.error(error)
            }

        })
    }

    func getRepoInformation() {
        do {
            let remote = try Remote().getRemoteURL(directoryURL: workspace.workspaceURL(),
                                                   name: "origin")
            let remoteURL = URL(string: remote!)
            let remoteSplit = remoteURL?.pathComponents

            repoOwner = remoteSplit?[1] ?? ""

            let repoValue = remoteSplit?[2] ?? ""

            repo = repoValue.replacingOccurrences(of: ".git", with: "")

            Log.debug("Repo Owner: \(repoOwner), Repo: \(repo)")
        } catch {
            Log.error("Failed to get project remote URL.")
        }
    }
}
