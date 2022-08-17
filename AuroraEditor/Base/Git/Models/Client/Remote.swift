//
//  Remote.swift
//  AuroraEditor
//
//  Created by Nanashi Li on 2022/08/12.
//  Copyright © 2022 Aurora Company. All rights reserved.
//  This source code is restricted for Aurora Editor usage only.
//

import Foundation

public struct Remote {

    /// List the remotes, sorted alphabetically by `name`, for a repository.
    func getRemotes(directoryURL: URL) throws -> [IRemote] {
        let result  = try ShellClient.live().run(
            "cd \(directoryURL.relativePath.escapedWhiteSpaces());git remote -v"
        )

        if result.contains("fatal: not a git repository") {
            return []
        }

        let output = result
        let lines = output.split(separator: "\n")
        // find a way to split ("/\s+/") with regex and then map it
//        let remotes = lines.filter {
//            $0.hasSuffix("(fetch)")
//        }

        return []
    }

    /// Add a new remote with the given URL.
    func addRemote(directoryURL: URL,
                   name: String,
                   url: String) throws -> IRemote? {
        let result = try ShellClient.live().run(
            "cd \(directoryURL.relativePath.escapedWhiteSpaces());git remote add"
        )

        return nil
    }

    /// Removes an existing remote, or silently errors if it doesn't exist
    func removeRemote(directoryURL: URL,
                      name: String) throws {
        try ShellClient().run(
            "cd \(directoryURL.relativePath.escapedWhiteSpaces());git remote remove"
        )

    }

    /// Changes the URL for the remote that matches the given name
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
    func getRemoteURL(directoryURL: URL,
                      name: String) throws -> String? {
        let result = try ShellClient.live().run(
            "cd \(directoryURL.relativePath.escapedWhiteSpaces());git remote get-url \(name)"
        )

        return result
    }

    /// Update the HEAD ref of the remote, which is the default branch.
    func updateRemoteHEAD(directoryURL: URL,
                          remote: IRemote) throws {
        try ShellClient().run(
            "cd \(directoryURL.relativePath.escapedWhiteSpaces());git remote set-head -a \(remote.name)"
        )
    }

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
}
