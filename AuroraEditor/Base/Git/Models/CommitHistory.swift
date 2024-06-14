//
//  CommitHistory.swift
//  Aurora Editor
//
//  Created by Marco Carnevali on 27/03/22.
//  Copyright © 2023 Aurora Company. All rights reserved.
//

import Foundation.NSDate

/// Model class to help map commit history log data
public struct CommitHistory: Equatable, Hashable, Identifiable {
    /// Unique identifier
    public var id = UUID()

    /// Hash
    public let hash: String

    /// Commit hash
    public let commitHash: String

    /// Commit message
    public let message: String

    /// Commit author
    public let author: String

    /// Commit author email
    public let authorEmail: String

    /// Commiter
    public let commiter: String

    /// Commiter email
    public let commiterEmail: String

    /// Remote URL
    public let remoteURL: URL?

    /// Date
    public let date: Date

    /// Is merge
    public let isMerge: Bool?

    /// Commit base URL
    public var commitBaseURL: URL? {
        if let remoteURL = remoteURL {
            if remoteURL.absoluteString.contains("github") {
                return parsedRemoteUrl(domain: "https://github.com", remote: remoteURL)
            }
            if remoteURL.absoluteString.contains("bitbucket") {
                return parsedRemoteUrl(domain: "https://bitbucket.org", remote: remoteURL)
            }
            if remoteURL.absoluteString.contains("gitlab") {
                return parsedRemoteUrl(domain: "https://gitlab.com", remote: remoteURL)
            }
            // TODO: Implement other git clients other than github, bitbucket here
        }
        return nil
    }

    /// Parsed remote URL
    /// 
    /// - Parameter domain: domain
    /// - Parameter remote: remote
    /// 
    /// - Returns: URL
    private func parsedRemoteUrl(domain: String, remote: URL) -> URL {
        // There are 2 types of remotes - https and ssh. While https has URL in its name, ssh doesnt.
        // Following code takes remote name in format profileName/repoName and prepends according domain
        var formattedRemote = remote
        if formattedRemote.absoluteString.starts(with: "git@") {
            let parts = formattedRemote.absoluteString.components(separatedBy: ":")
            formattedRemote = URL(fileURLWithPath: "\(domain)/\(parts[parts.count - 1])")
        }

        return formattedRemote.deletingPathExtension().appendingPathComponent("commit")
    }

    /// Remote as string
    public var remoteString: String {
        if let remoteURL = remoteURL {
            if remoteURL.absoluteString.contains("github") {
                return "GitHub"
            }
            if remoteURL.absoluteString.contains("bitbucket") {
                return "BitBucket"
            }
            if remoteURL.absoluteString.contains("gitlab") {
                return "GitLab"
            }
        }
        return "Remote"
    }
}
