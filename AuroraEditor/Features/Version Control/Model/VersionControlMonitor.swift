//
//  VersionControlMonitor.swift
//  Aurora Editor
//
//  Created by Nanashi Li on 2024/07/09.
//  Copyright © 2024 Aurora Company. All rights reserved.
//

import Foundation
import Combine

/// A class responsible for monitoring changes in the Git repository directory
/// and updating the version control information accordingly.
class VersionControlMonitor {

    /// The URL of the workspace being monitored.
    private var workspaceURL: URL

    /// The file descriptor for the `.git/logs/HEAD` file.
    private var headDescriptor: Int32 = -1

    /// The file descriptor for the `.git/refs/heads` directory.
    private var refsDescriptor: Int32 = -1

    /// The file descriptor for the `.git/refs/remotes` directory.
    private var remotesDescriptor: Int32 = -1

    /// The dispatch source for monitoring the `.git/logs/HEAD` file.
    private var headSource: DispatchSourceFileSystemObject?

    /// The dispatch source for monitoring the `.git/refs/heads` directory.
    private var refsSource: DispatchSourceFileSystemObject?

    /// The file descriptor for the `.git/refs/remotes` directory.
    private var remotesSource: DispatchSourceFileSystemObject?

    /// A cancellable timer used for debouncing file system events.
    private var debounceTimer: AnyCancellable?

    /// The interval for debouncing file system events.
    private let debounceInterval: TimeInterval = 1.0

    /// The dispatch queue used for monitoring file system events.
    private let monitorQueue = DispatchQueue(label: "com.auroraeditor.git.monitor", qos: .background)

    /// The shared version control model.
    private let versionControl: VersionControlModel = .shared

    /// Initializes a new instance of `VersionControlMonitor` with the specified workspace URL.
    /// - Parameter workspaceURL: The URL of the workspace to monitor.
    init(workspaceURL: URL) {
        self.workspaceURL = workspaceURL
    }

    deinit {
        stopMonitoringGitDirectory()
    }

    /// Starts monitoring the Git directory for changes.
    func startMonitoringGitDirectory() {
        monitorQueue.async { [weak self] in
            self?.setupMonitoring()
        }
    }

    /// Sets up monitoring for the Git directory by creating dispatch sources
    /// for the `.git/logs/HEAD` file, the `.git/refs/heads` and `.git/refs/remotes` directory.
    private func setupMonitoring() {
        setupGitMonitoring(
            for: ".git/logs/HEAD",
            descriptor: &headDescriptor,
            source: &headSource,
            eventMask: .all
        )
        setupGitMonitoring(
            for: ".git/refs/heads",
            descriptor: &refsDescriptor,
            source: &refsSource,
            eventMask: [.write, .rename, .delete]
        )
        setupGitMonitoring(
            for: ".git/refs/remotes",
            descriptor: &remotesDescriptor,
            source: &remotesSource,
            eventMask: [.write, .rename, .delete]
        )
    }

    private func setupGitMonitoring(
        for relativePath: String,
        descriptor: inout Int32,
        source: inout DispatchSourceFileSystemObject?,
        eventMask: DispatchSource.FileSystemEvent
    ) {
        let gitPath = workspaceURL.appendingPathComponent(relativePath)

        descriptor = open(gitPath.path, O_EVTONLY)
        guard descriptor != -1 else { return }

        source = DispatchSource.makeFileSystemObjectSource(
            fileDescriptor: descriptor,
            eventMask: eventMask,
            queue: monitorQueue
        )

        source?.setEventHandler { [weak self] in
            self?.handleGitDirectoryChange()
        }

        source?.setCancelHandler { [descriptor] in
            close(descriptor)
        }

        source?.resume()
    }

    /// Handles changes in the Git directory by using a debounce timer to
    /// limit the frequency of updates.
    private func handleGitDirectoryChange() {
        debounceTimer?.cancel()
        debounceTimer = Just(())
            .delay(for: .seconds(debounceInterval), scheduler: monitorQueue)
            .sink { [weak self] _ in
                self?.updateGitInfo()
            }
    }

    /// Updates the version control information by checking if the workspace is
    /// a repository and fetching recent branches and current branches.
    private func updateGitInfo() {
        versionControl.checkIfWorkspaceIsRepository()

        Task {
            await versionControl.getWorkspaceRecentBranches()
            await versionControl.getWorkspaceBranches()
            await versionControl.getRemoteURL()
            await versionControl.getRemoteChangeFiles()
        }
    }

    /// Stops monitoring the Git directory by cancelling the debounce timer
    /// and closing the file descriptors.
    func stopMonitoringGitDirectory() {
        monitorQueue.sync {
            debounceTimer?.cancel()
            headSource?.cancel()
            headSource = nil

            refsSource?.cancel()
            refsSource = nil

            remotesSource?.cancel()
            remotesSource = nil

            if headDescriptor != -1 {
                close(headDescriptor)
                headDescriptor = -1
            }

            if refsDescriptor != -1 {
                close(refsDescriptor)
                refsDescriptor = -1
            }

            if remotesDescriptor != -1 {
                close(remotesDescriptor)
                remotesDescriptor = -1
            }
        }
    }
}
