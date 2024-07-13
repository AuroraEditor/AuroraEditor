//
//  WorkspaceGitStatus.swift
//  Aurora Editor
//
//  Created by Nanashi Li on 2024/07/06.
//  Copyright © 2024 Aurora Company. All rights reserved.
//

import Foundation
import Version_Control

class WorkspaceGitStatus: ObservableObject {

    // Singleton instance
    public static var shared: WorkspaceGitStatus!

    @Published
    public var workspaceStatus: StatusResult?

    private let workspaceURL: URL

    // Private initializer to enforce singleton usage
    private init(workspaceURL: URL) {
        self.workspaceURL = workspaceURL
        Task {
            await fetchGitStatus()
        }
    }

    // Method to initialize the singleton instance
    public static func initialize(workspaceURL: URL) {
        guard shared == nil else {
            return
        }
        shared = WorkspaceGitStatus(workspaceURL: workspaceURL)
    }

    @MainActor
    private func fetchGitStatus() async {
        do {
            let status = try await GitStatus().getStatus(directoryURL: workspaceURL)
            self.workspaceStatus = status
        } catch {
            self.workspaceStatus = nil
        }
    }
}
