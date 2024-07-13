//
//  SourceControlModel.swift
//  Aurora Editor
//
//  Created by Nanashi Li on 2022/05/20.
//  Copyright © 2023 Aurora Company. All rights reserved.
//

import Foundation
import Combine
import Version_Control
import OSLog

/// This model handle the fetching and adding of changes etc... for the
/// Source Control Navigator
public final class SourceControlModel: ObservableObject {
    /// The state of the model
    enum State {
        case loading, error, success
    }

    /// The current state of the model
    @Published
    var state: State = .loading

    /// A GitClient instance
    let gitClient: GitClient

    /// A FileSystemClient instance, but set to the .git repo (if it exists)
    var fileSystemClient: FileSystemClient?

    /// The base URL of the workspace
    let workspaceURL: URL

    /// A list of changed files
    @Published
    public var changed: [FileItem]

    /// Whether the workspace is a git repository
    @Published
    public var isGitRepository: Bool = false

    /// A set of cancellables
    private var cancellables = Set<AnyCancellable>()

    /// Logger
    let logger = Logger(subsystem: "com.auroraeditor", category: "Source Control Model")

    /// Initialize with a GitClient
    /// 
    /// - Parameter workspaceURL: the current workspace URL we also need this to open files in finder
    public init(workspaceURL: URL) {
        self.workspaceURL = workspaceURL
        self.isGitRepository = Check().checkIfProjectIsRepo(workspaceURL: workspaceURL)
        gitClient = GitClient(
            directoryURL: workspaceURL,
            shellClient: sharedShellClient.shellClient
        )
        do {
            changed = try gitClient.getChangedFiles()

            DispatchQueue.main.async {
                self.state = .success
            }
        } catch {
            changed = []

            DispatchQueue.main.async {
                self.state = .success
            }
        }
    }

    /// Discard changes for a file
    /// 
    /// - Parameter file: the file to discard changes for
    public func discardFileChanges(file: FileItem) {
        do {
            try gitClient.discardFileChanges(url: file.url.path)
        } catch {
            self.logger.fault("Failed to discard changes")
        }
    }

    /// Discard changes for the project
    public func discardProjectChanges() {
        do {
            try gitClient.discardProjectChanges()
        } catch {
            self.logger.fault("Failed to discard changes")
        }
    }

    /// Is reloading
    private var isReloading: Bool = false

    /// Reload the changed files
    /// 
    /// - Returns: the files that have changed
    @discardableResult
    public func reloadChangedFiles() -> [FileItem] {
        guard !isReloading else { return [] }

        isReloading = true

        do {
            let newChanged = try gitClient.getChangedFiles()

            let oldUrls = Set(changed.map { $0.url })
            let newUrls = Set(newChanged.map { $0.url })

            let differentUrls = oldUrls.symmetricDifference(newUrls)
            let differentFiles = (changed + newChanged).filter {
                differentUrls.contains($0.url)
            }

            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                if !differentFiles.isEmpty {
                    self.changed = newChanged
                }
                self.state = .success
                self.isReloading = false
            }

            return differentFiles
        } catch {
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                self.changed = []
                self.state = .success
                self.isReloading = false
            }
            return []
        }
    }
}
