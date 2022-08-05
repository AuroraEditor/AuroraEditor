//
//  CrashReportModel.swift
//  
//
//  Created by Nanashi Li on 2022/07/31.
//

import Foundation
import SwiftUI

public class CrashReportModel: ObservableObject {

    public static let shared: CrashReportModel = .init()

    private var prefs: AppPreferencesModel = .shared
    private let keychain = AuroraEditorKeychain()

    @Environment(\.openURL) var openIssueURL

    @Published
    var isSubmitted: Bool = false
    @Published
    var failedToSubmit: Bool = false
    @Published
    var comments: String = ""

    /// The format for the issue body is how it will be displayed on
    /// repos issues. If any changes are made use markdown format
    /// because the text gets converted when created.
    private func createIssueBody(comments: String,
                                 crashData: String) -> String {
        """
        **Comments**

        \(comments)

        **Crash Information**

        \(crashData)
        """
    }

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
                Log.error(error.localizedDescription)
            }
        }
    }
}
