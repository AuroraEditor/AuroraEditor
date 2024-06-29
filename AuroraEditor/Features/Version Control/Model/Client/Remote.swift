//
//  Remote.swift
//  Aurora Editor
//
//  Created by Nanashi Li on 2022/08/12.
//  Copyright © 2023 Aurora Company. All rights reserved.
//
//  This source code is restricted for Aurora Editor usage only.
//

import Foundation

/// GIT remote
public struct Remote {
    /// List the remotes, sorted alphabetically by `name`, for a repository.
    /// 
    /// - Parameter directoryURL: The directory to list the remotes in.
    /// 
    /// - Returns: The list of remotes.
    /// 
    /// - Throws: Error
    func getRemotes(directoryURL: URL) throws -> [IRemote] {
        let result = try ShellClient.live().run(
            "cd \(directoryURL.relativePath.escapedWhiteSpaces());git remote -v"
        )

        if result.contains(GitError.notAGitRepository.rawValue) {
            return []
        }

        let lines = result.split(separator: "\n")
        let remotes = lines.filter {
            $0.hasSuffix("(fetch)")
        }.map {
            $0.split(separator: "\t")
        }.map {
            GitRemote(name: $0[0].description,
                      url: $0[1].description)
        }

        return remotes
    }

    /// Add a new remote with the given URL.
    /// 
    /// - Parameter directoryURL: The directory to add the remote to.
    /// - Parameter name: The name of the remote.
    /// - Parameter url: The URL of the remote.
    /// 
    /// - Returns: The remote that was added.
    /// 
    /// - Throws: Error
    func addRemote(directoryURL: URL,
                   name: String,
                   url: String) throws -> GitRemote? {
        try ShellClient.live().run(
            "cd \(directoryURL.relativePath.escapedWhiteSpaces());git remote add \(name) \(url)"
        )

        return GitRemote(name: name, url: url)
    }

    /// Removes an existing remote, or silently errors if it doesn't exist
    /// 
    /// - Parameter directoryURL: The directory to remove the remote from.
    /// - Parameter name: The name of the remote.
    /// 
    /// - Throws: Error
    func removeRemote(directoryURL: URL,
                      name: String) throws {
        try ShellClient().run(
            "cd \(directoryURL.relativePath.escapedWhiteSpaces());git remote remove"
        )

    }

    /// Changes the URL for the remote that matches the given name
    /// 
    /// - Parameter directoryURL: The directory to change the remote URL in.
    /// - Parameter name: The name of the remote.
    /// - Parameter url: The new URL of the remote.
    /// 
    /// - Returns: True if the remote was updated.
    /// 
    /// - Throws: Error
    func setRemoteURL(directoryURL: URL,
                      name: String,
                      url: String) throws -> Bool {
        try ShellClient().run(
            "cd \(directoryURL.relativePath.escapedWhiteSpaces());git remote set-url \(name) \(url)"
        )

        return true
    }

    /// Get the URL for the remote that matches the given name.
    ///
    /// Returns null if the remote could not be found
    /// 
    /// - Parameter directoryURL: The directory to get the remote URL from.
    /// - Parameter name: The name of the remote.
    /// 
    /// - Returns: The URL of the remote.
    /// 
    /// - Throws: Error
    func getRemoteURL(directoryURL: URL,
                      name: String) throws -> String? {
        let result = try ShellClient.live().run(
            "cd \(directoryURL.relativePath.escapedWhiteSpaces());git remote get-url \(name)"
        )

        return result.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    /// Update the HEAD ref of the remote, which is the default branch.
    /// 
    /// - Parameter directoryURL: The directory to update the remote HEAD in.
    /// - Parameter remote: The remote to update the HEAD for.
    /// 
    /// - Throws: Error
    func updateRemoteHEAD(directoryURL: URL,
                          remote: IRemote) throws {
        try ShellClient().run(
            "cd \(directoryURL.relativePath.escapedWhiteSpaces());git remote set-head -a \(remote.name)"
        )
    }

    /// Get the HEAD ref of the remote, which is the default branch.
    /// 
    /// - Parameter directoryURL: The directory to get the remote HEAD from.
    /// - Parameter remote: The remote to get the HEAD for.
    /// 
    /// - Returns: The HEAD ref of the remote.
    /// 
    /// - Throws: Error
    func getRemoteHEAD(directoryURL: URL,
                       remote: String) throws -> String? {
        let remoteNamespace = "refs/remotes/\(remote)/"
        let match = try Refs().getSymbolicRef(directoryURL: directoryURL,
                                          ref: "\(remoteNamespace)HEAD")

        if match != nil && match!.count > remoteNamespace.count
            && match!.starts(with: remoteNamespace) {
            return match!.substring(remoteNamespace.count)
        }

        return nil
    }

    /// Get the branches of the remote.
    /// 
    /// - Parameter directoryURL: The directory to get the remote branches from.
    /// 
    /// - Returns: The branches of the remote.
    /// 
    /// - Throws: Error
    func getRemoteHEAD(url: String) throws -> [String] {
        return try ShellClient.live().run(
            "git ls-remote -q --symref \(url) | head -1 | cut -f1 | sed 's!^ref: refs/heads/!!'"
        ).components(separatedBy: "\n").filter { !$0.isEmpty }
    }

    /// Get the branches of the remote.
    /// 
    /// - Parameter url: The URL of the remote.
    /// 
    /// - Returns: The branches of the remote.
    /// 
    /// - Throws: Error
    func getRemoteBranch(url: String) throws -> [String] {
        return try ShellClient.live().run(
            "git ls-remote \(url) --h --sort origin \"refs/heads/*\" | cut -f2 | sed 's!^refs/heads/!!'"
        ).components(separatedBy: "\n").filter { !$0.isEmpty }
    }
}
