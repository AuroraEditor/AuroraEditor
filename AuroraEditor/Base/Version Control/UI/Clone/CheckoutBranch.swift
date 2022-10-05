//
//  CheckoutBranch.swift
//  AuroraEditorModules/Git
//
//  Created by Aleksi Puttonen on 18.4.2022.
//

import Foundation
import SwiftUI

// TODO: DOCS (Aleksi Puttonen)
public extension CheckoutBranchView {
    func getBranches() -> [String] {
        guard let url = URL(string: repoPath) else {
            return [""]
        }
        do {
            let branches = try GitClient.init(
                directoryURL: url,
                shellClient: shellClient
            ).getGitBranches(allBranches: true)

            return branches
        } catch {
            return [""]
        }
    }

    // swiftlint:disable:next function_body_length
    func checkoutBranch() {
        var parsedBranch = selectedBranch
        if selectedBranch.contains("origin/") || selectedBranch.contains("upstream/") {
            parsedBranch = selectedBranch.components(separatedBy: "/")[1]
        }
        do {
            if let url = URL(string: repoPath) {
                try GitClient.init(directoryURL: url,
                                   shellClient: shellClient).checkoutBranch(name: parsedBranch)
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
            case .badConfigFile:
                alert.messageText = "Failed to decode URL"
            case .authenticationFailed:
                alert.messageText = "Failed to decode URL"
            case .noUserNameConfigured:
                alert.messageText = "Failed to decode URL"
            case .noUserEmailConfigured:
                alert.messageText = "Failed to decode URL"
            case .notAGitRepository:
                alert.messageText = "Failed to decode URL"
            case .notAtRepositoryRoot:
                alert.messageText = "Failed to decode URL"
            case .conflict:
                alert.messageText = "Failed to decode URL"
            case .stashConflict:
                alert.messageText = "Failed to decode URL"
            case .unmergedChanges:
                alert.messageText = "Failed to decode URL"
            case .pushRejected:
                alert.messageText = "Failed to decode URL"
            case .remoteConnectionError:
                alert.messageText = "Failed to decode URL"
            case .dirtyWorkTree:
                alert.messageText = "Failed to decode URL"
            case .cantOpenResource:
                alert.messageText = "Failed to decode URL"
            case .gitNotFound:
                alert.messageText = "Failed to decode URL"
            case .cantCreatePipe:
                alert.messageText = "Failed to decode URL"
            case .cantAccessRemote:
                alert.messageText = "Failed to decode URL"
            case .repositoryNotFound:
                alert.messageText = "Failed to decode URL"
            case .repositoryIsLocked:
                alert.messageText = "Failed to decode URL"
            case .branchNotFullyMerged:
                alert.messageText = "Failed to decode URL"
            case .noRemoteReference:
                alert.messageText = "Failed to decode URL"
            case .invalidBranchName:
                alert.messageText = "Failed to decode URL"
            case .branchAlreadyExists:
                alert.messageText = "Failed to decode URL"
            case .noLocalChanges:
                alert.messageText = "Failed to decode URL"
            case .noStashFound:
                alert.messageText = "Failed to decode URL"
            case .localChangesOverwritten:
                alert.messageText = "Failed to decode URL"
            case .noUpstreamBranch:
                alert.messageText = "Failed to decode URL"
            case .isInSubModule:
                alert.messageText = "Failed to decode URL"
            case .wrongCase:
                alert.messageText = "Failed to decode URL"
            case .cantLockRef:
                alert.messageText = "Failed to decode URL"
            case .cantRebaseMultipleBranches:
                alert.messageText = "Failed to decode URL"
            case .patchDoesNotApply:
                alert.messageText = "Failed to decode URL"
            }
            alert.runModal()
        }
    }
}
