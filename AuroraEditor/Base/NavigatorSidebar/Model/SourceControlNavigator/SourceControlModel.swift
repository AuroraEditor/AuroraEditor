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
    public var changed: [ChangedFile]

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

        // check if .git repo exists
        if WorkspaceClient.FileItem.fileManger.fileExists(atPath:
            workspaceURL.appendingPathComponent(".git").path) {
            self.workspaceClient = try? .default(fileManager: .default,
                                                 folderURL: workspaceURL.appendingPathExtension(".git"),
                                                 ignoredFilesAndFolders: ["hooks"],
                                                 onUpdate: { self.changed = (try? self.gitClient.getChangedFiles())! })
            workspaceClient?
                .getFiles
                .sink { files in
                    files.forEach {
                        _ = $0.activateWatcher()
                    }
                }
                .store(in: &cancellables)
        }
    }

    public func discardFileChanges(file: ChangedFile) {
        do {
            try gitClient.discardFileChanges(file.fileLink.path)
        } catch {
            print("Failed to discard changes")
        }
    }

    public func discardProjectChanges() {
        do {
            try gitClient.discardProjectChanges()
        } catch {
            print("Failed to discard changes")
        }
    }
}
