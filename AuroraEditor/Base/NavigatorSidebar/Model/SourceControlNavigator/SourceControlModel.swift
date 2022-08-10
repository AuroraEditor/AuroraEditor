//
//  SourceControlModel.swift
//  AuroraEditor
//
//  Created by Nanashi Li on 2022/05/20.
//

import Foundation
import Combine

/// This model handle the fetching and adding of changes etc... for the
/// Source Control Navigator
public final class SourceControlModel: ObservableObject {

    enum State {
        case loading
        case error
        case success
    }

    @Published
    var state: State = .loading

    /// A GitClient instance
    let gitClient: GitClient

    /// A WorkspaceClient instance, but set to the .git repo (if it exists)
    var workspaceClient: WorkspaceClient?

    /// The base URL of the workspace
    let workspaceURL: URL

    /// A list of changed files
    @Published
    public var changed: [FileItem]

    private var cancellables = Set<AnyCancellable>()

    /// Initialize with a GitClient
    /// - Parameter workspaceURL: the current workspace URL we also need this to open files in finder
    ///
    public init(workspaceURL: URL) {
        self.workspaceURL = workspaceURL
        gitClient = GitClient.default(
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

    public func discardFileChanges(file: FileItem) {
        do {
            try gitClient.discardFileChanges(file.url.path)
        } catch {
            Log.error("Failed to discard changes")
        }
    }

    public func discardProjectChanges() {
        do {
            try gitClient.discardProjectChanges()
        } catch {
            Log.error("Failed to discard changes")
        }
    }

    public func reloadChangedFiles() -> [FileItem] {
        do {
            let newChanged = try gitClient.getChangedFiles()
            DispatchQueue.main.async { self.state = .success }
            let difference = newChanged.map({ $0.url }).difference(from: changed.map({ $0.url }))
            var differentFiles = newChanged.filter { difference.contains($0.url) }
            differentFiles += changed.filter { difference.contains($0.url) }
            changed = newChanged
            return differentFiles
        } catch {
            changed = []
            DispatchQueue.main.async { self.state = .success }
        }
        return []
    }
}
