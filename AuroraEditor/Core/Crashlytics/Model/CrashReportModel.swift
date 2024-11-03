//
//  CrashReportModel.swift
//  Aurora Editor
//
//  Created by Nanashi Li on 2022/07/31.
//  Copyright © 2023 Aurora Company. All rights reserved.
//

import Foundation
import SwiftUI
import OSLog

// This model handles sending crash report data to the Aurora Editor
// Github repo.
@MainActor
public class CrashReportModel: ObservableObject {
    /// The shared instance of the crash report model.
    public static let shared: CrashReportModel = .init()

    /// The app preferences model.
    private var prefs: AppPreferencesModel = .shared

    /// The keychain.
    private let keychain = AuroraEditorKeychain()

    /// Logger
    let logger = Logger(subsystem: "com.auroraeditor", category: "Crash Report Model")

    /// The open URL environment.
    @Environment(\.openURL)
    var openIssueURL

    /// is Submitted?
    @Published
    var isSubmitted: Bool = false

    /// failed to submit?
    @Published
    var failedToSubmit: Bool = false

    /// The comments for the issue.
    @Published
    var comments: String = ""

    /// The format for the issue body is how it will be displayed on
    /// repos issues. If any changes are made use markdown format
    /// because the text gets converted when created.
    /// 
    /// - Parameter comments: The comments for the issue.
    /// - Parameter crashData: The crash data for the issue.
    /// 
    /// - Returns: The formatted issue body.
    private func createIssueBody(comments: String,
                                 crashData: String) -> String {
        """
        **Comments**

        \(comments)

        **Crash Information**

        \(crashData)
        """
    }

    // God I was fucking stupid here! What is this logic omfg
    /// Creates a Github Issue
    ///
    /// - Parameter comments: The comments for the issue.
    /// - Parameter crashData: The crash data for the issue.
    public func createIssue(comments: String,
                            crashData: String) {
        var gitAccounts: [AccountPreferences] = []

        do {
            gitAccounts = try AccountPreferences.fetchAll()
        } catch {
            self.logger.fault("Failed to fetch accounts")
        }

        guard let firstGitAccount = gitAccounts.first else {
            return
        }

        let config = GithubTokenConfiguration(keychain.get(firstGitAccount.accountName))
        GithubAccount(config).postIssue(owner: "AuroraEditor",
                                        repository: "AuroraEditor",
                                        title: "💣 - Crash - ID: \(UUID().uuidString)",
                                        body: createIssueBody(comments: comments,
                                                              crashData: crashData),
                                        assignee: "",
                                        labels: ["Crash", "Editor"]) { response in
            switch response {
            case .success:
                self.isSubmitted.toggle()
            case .failure(let error):
                self.failedToSubmit.toggle()
                self.logger.fault("\(error.localizedDescription)")
            }
        }
    }
}
