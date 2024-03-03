//
//  CheckoutBranch.swift
//  Aurora Editor
//
//  Created by Aleksi Puttonen on 18.4.2022.
//  Copyright © 2023 Aurora Company. All rights reserved.
//

import Foundation
import SwiftUI
import Version_Control

public extension CheckoutBranchView {
    /// Get branches
    /// - Returns: branches
    func getBranches() -> [String] {
        guard let url = URL(string: repoPath) else {
            return [""]
        }
        do {
            let branches = try Branch().getBranches(directoryURL: url)
            return branches.map { $0.name }
        } catch {
            return [""]
        }
    }

    /// Checkout in branch
    func checkoutBranch() {
        var parsedBranch = selectedBranch
        if selectedBranch.contains("origin/") || selectedBranch.contains("upstream/") {
            parsedBranch = selectedBranch.components(separatedBy: "/")[1]
        }
        do {
            if let url = URL(string: repoPath) {
                try GitClient(directoryURL: url,
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
            default:
                alert.messageText = "Failed to decode URL"
            }
            alert.runModal()
        }
    }
}
