//
//  CrashReportModel.swift
//  Aurora Editor
//
//  Created by Nanashi Li on 2022/07/31.
//  Copyright © 2023 Aurora Company. All rights reserved.
//

import Foundation
import SwiftUI

// This model handles sending crash report data to the Aurora Editor
// Github repo.
public class CrashReportModel: ObservableObject {
    /// The shared instance of the crash report model.
    public static let shared: CrashReportModel = .init()

    /// The app preferences model.
    private var prefs: AppPreferencesModel = .shared

    /// The keychain.
    private let keychain = AuroraEditorKeychain()

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

    /// Creates a Github Issue
    ///
    /// - Parameter comments: The comments for the issue.
    /// - Parameter crashData: The crash data for the issue.
    public func createIssue(comments: String,
                            crashData: String) {
        let gitAccounts = prefs.preferences.accounts.sourceControlAccounts.gitAccount
        let firstGitAccount = gitAccounts.first

        let config = GithubTokenConfiguration(keychain.get(firstGitAccount!.gitAccountName))
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
                Log.fault("\(error.localizedDescription)")
            }
        }
    }
}
