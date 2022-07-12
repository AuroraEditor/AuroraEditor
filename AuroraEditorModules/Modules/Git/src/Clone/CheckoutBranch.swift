//
//  CheckoutBranch.swift
//  CodeEditModules/Git
//
//  Created by Aleksi Puttonen on 18.4.2022.
//

import Foundation
import SwiftUI

// TODO: DOCS (Aleksi Puttonen)
// swiftlint:disable missing_docs
public extension CheckoutBranchView {
    func getBranches() -> [String] {
        guard let url = URL(string: repoPath) else {
            return [""]
        }
        do {
            let branches = try GitClient.default(directoryURL: url,
                                                 shellClient: shellClient).getBranches(true)
            return branches
        } catch {
            return [""]
        }
    }
    func checkoutBranch() {
        var parsedBranch = selectedBranch
        if selectedBranch.contains("origin/") || selectedBranch.contains("upstream/") {
            parsedBranch = selectedBranch.components(separatedBy: "/")[1]
        }
        do {
            if let url = URL(string: repoPath) {
                try GitClient.default(directoryURL: url,
                                      shellClient: shellClient).checkoutBranch(parsedBranch)
                isPresented = false
            }
        } catch {
            guard let error = error as? GitClient.GitClientError else { return }
            let alert = NSAlert()
            alert.alertStyle = .critical
            alert.addButton(withTitle: "Ok")
            switch error {
            case .notGitRepository:
                alert.messageText = "Not a git repository"
            case let .outputError(message):
                alert.messageText = message
            case .failedToDecodeURL:
                alert.messageText = "Failed to decode URL"
            case .BadConfigFile:
                alert.messageText = "Failed to decode URL"
            case .AuthenticationFailed:
                alert.messageText = "Failed to decode URL"
            case .NoUserNameConfigured:
                alert.messageText = "Failed to decode URL"
            case .NoUserEmailConfigured:
                alert.messageText = "Failed to decode URL"
            case .NotAGitRepository:
                alert.messageText = "Failed to decode URL"
            case .NotAtRepositoryRoot:
                alert.messageText = "Failed to decode URL"
            case .Conflict:
                alert.messageText = "Failed to decode URL"
            case .StashConflict:
                alert.messageText = "Failed to decode URL"
            case .UnmergedChanges:
                alert.messageText = "Failed to decode URL"
            case .PushRejected:
                alert.messageText = "Failed to decode URL"
            case .RemoteConnectionError:
                alert.messageText = "Failed to decode URL"
            case .DirtyWorkTree:
                alert.messageText = "Failed to decode URL"
            case .CantOpenResource:
                alert.messageText = "Failed to decode URL"
            case .GitNotFound:
                alert.messageText = "Failed to decode URL"
            case .CantCreatePipe:
                alert.messageText = "Failed to decode URL"
            case .CantAccessRemote:
                alert.messageText = "Failed to decode URL"
            case .RepositoryNotFound:
                alert.messageText = "Failed to decode URL"
            case .RepositoryIsLocked:
                alert.messageText = "Failed to decode URL"
            case .BranchNotFullyMerged:
                alert.messageText = "Failed to decode URL"
            case .NoRemoteReference:
                alert.messageText = "Failed to decode URL"
            case .InvalidBranchName:
                alert.messageText = "Failed to decode URL"
            case .BranchAlreadyExists:
                alert.messageText = "Failed to decode URL"
            case .NoLocalChanges:
                alert.messageText = "Failed to decode URL"
            case .NoStashFound:
                alert.messageText = "Failed to decode URL"
            case .LocalChangesOverwritten:
                alert.messageText = "Failed to decode URL"
            case .NoUpstreamBranch:
                alert.messageText = "Failed to decode URL"
            case .IsInSubModule:
                alert.messageText = "Failed to decode URL"
            case .WrongCase:
                alert.messageText = "Failed to decode URL"
            case .CantLockRef:
                alert.messageText = "Failed to decode URL"
            case .CantRebaseMultipleBranches:
                alert.messageText = "Failed to decode URL"
            case .PatchDoesNotApply:
                alert.messageText = "Failed to decode URL"
            }
            alert.runModal()
        }
    }
}
