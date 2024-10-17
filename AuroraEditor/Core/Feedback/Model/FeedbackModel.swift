//
//  FeedbackModel.swift
//  Aurora Editor
//
//  Created by Nanashi Li on 2022/04/14.
//  Copyright © 2023 Aurora Company. All rights reserved.
//

import SwiftUI
import OSLog

/// Feedback model
@MainActor
public class FeedbackModel: ObservableObject {
    /// Shared instance
    public static let shared: FeedbackModel = .init()
    // Accessing Environment<OpenURLAction>'s
    // value outside of being installed on a View.
    // This will always read the default value and will not update.

    /// App preferences
    private var prefs: AppPreferencesModel = .shared

    /// Keychain
    private let keychain = AuroraEditorKeychain()

    /// Open URL environment
    @Environment(\.openURL)
    var openIssueURL

    /// is submitted
    @Published
    var isSubmitted: Bool = false

    /// failed to submit
    @Published
    var failedToSubmit: Bool = false

    /// Feedback title
    @Published
    var feedbackTitle: String = ""

    /// Issue description
    @Published
    var issueDescription: String = ""

    /// Steps to reproduce description
    @Published
    var stepsReproduceDescription: String = ""

    /// Expectation description
    @Published
    var expectationDescription: String = ""

    /// What happened description
    @Published
    var whatHappenedDescription: String = ""

    /// Issue area list selection
    @Published
    var issueAreaListSelection: IssueArea.ID = "none"

    /// Feedback type list selection
    @Published
    var feedbackTypeListSelection: FeedbackType.ID = "none"

    /// Feedback type list
    @Published
    var feedbackTypeList = [FeedbackType(name: "Choose...", id: "none"),
                            FeedbackType(name: "Incorrect/Unexpected Behaviour", id: "behaviour"),
                            FeedbackType(name: "Application Crash", id: "crash"),
                            FeedbackType(name: "Application Slow/Unresponsive", id: "unresponsive"),
                            FeedbackType(name: "Suggestion", id: "suggestions"),
                            FeedbackType(name: "Other", id: "other")]

    /// Issue area list
    @Published
    var issueAreaList = [IssueArea(name: "Please select the problem area", id: "none"),
                         IssueArea(name: "Project Navigator", id: "projectNavigator"),
                         IssueArea(name: "Extensions", id: "extensions"),
                         IssueArea(name: "Git", id: "git"),
                         IssueArea(name: "Debugger", id: "debugger"),
                         IssueArea(name: "Editor", id: "editor"),
                         IssueArea(name: "Other", id: "other")]

    /// Logger
    let logger = Logger(subsystem: "com.auroraeditor", category: "Feeback model")

    /// Gets the ID of the selected issue type and then
    /// cross references it to select the right Label based on the type
    ///
    /// - Returns: issue label
    private func getIssueLabel() -> String {
        switch issueAreaListSelection {
        case "projectNavigator":
            return "Project Navigator"
        case "extensions":
            return "Extensions"
        case "git":
            return "Git"
        case "debugger":
            return "Debugger"
        case "editor":
            return "Editor"
        case "other":
            return "Other"
        default:
            return "Other"
        }
    }

    /// This is just temporary till we have bot that will handle this
    /// Get feedback type title
    ///
    /// - Returns: feedback type title
    private func getFeebackTypeTitle() -> String {
        switch feedbackTypeListSelection {
        case "behaviour":
            return "🐞"
        case "crash":
            return "🐞"
        case "unresponsive":
            return "🐞"
        case "suggestions":
            return "✨"
        case "other":
            return "📬"
        default:
            return "Other"
        }
    }

    /// Gets the ID of the selected feedback type and then
    /// cross references it to select the right Label based on the type
    ///
    /// - Returns: feedback type label
    private func getFeebackTypeLabel() -> String {
        switch feedbackTypeListSelection {
        case "behaviour":
            return "Bug"
        case "crash":
            return "Bug"
        case "unresponsive":
            return "Bug"
        case "suggestions":
            return "Suggestion"
        case "other":
            return "Feedback"
        default:
            return "Other"
        }
    }

    /// The format for the issue body is how it will be displayed on
    /// repos issues. If any changes are made use markdown format
    /// because the text gets converted when created.
    ///
    /// - Parameter description: description
    /// - Parameter steps: steps
    /// - Parameter expectation: expectation
    /// - Parameter actuallyHappened: actually happened
    ///
    /// - Returns: issue body
    private func createIssueBody(description: String,
                                 steps: String?,
                                 expectation: String?,
                                 actuallyHappened: String?) -> String {
        """
        **Description**

        \(description)

        **Steps to Reproduce**

        \(steps ?? "N/A")

        **What did you expect to happen?**

        \(expectation ?? "N/A")

        **What actually happened?**

        \(actuallyHappened ?? "N/A")
        """
    }

    /// Create issue
    ///
    /// - Parameter title: title
    /// - Parameter description: description
    /// - Parameter steps: steps
    /// - Parameter expectation: expectation
    /// - Parameter actuallyHappened: actually happened
    public func createIssue(
        // swiftlint:disable:previous function_body_length
        title: String,
        description: String,
        steps: String?,
        expectation: String?,
        actuallyHappened: String?
    ) {
        var gitAccounts: [AccountPreferences] = []

        do {
            gitAccounts = try AccountPreferences.fetchAll()
        } catch {
            self.logger.fault("Failed to fetch accounts")
        }

        guard let firstGitAccount = gitAccounts.first else {
            self.logger.warning("Did not find an account name.")
            guard let safeTitle = "\(getFeebackTypeTitle()) \(title)"
                .addingPercentEncoding(withAllowedCharacters: .urlHostAllowed),
                  let safeBody = createIssueBody(description: description,
                                                 steps: steps,
                                                 expectation: expectation,
                                                 actuallyHappened: actuallyHappened)
                .addingPercentEncoding(withAllowedCharacters: .urlHostAllowed),
                  let issueURL = URL(
                    string: "https://github.com/AuroraEditor/AuroraEditor/issues/" +
                    "new?title=\(safeTitle)&body=\(safeBody)"
                  ) else {
                self.logger.fault("Failed to generate URL")
                return
            }

            self.openIssueURL(issueURL)
            isSubmitted.toggle()
            return
        }

        let config = GithubTokenConfiguration(keychain.get(firstGitAccount.accountName))
        GithubAccount(config).postIssue(owner: "AuroraEditor",
                                        repository: "AuroraEditor",
                                        title: "\(getFeebackTypeTitle()) \(title)",
                                        body: createIssueBody(description: description,
                                                              steps: steps,
                                                              expectation: expectation,
                                                              actuallyHappened: actuallyHappened),
                                        assignee: "",
                                        labels: [getFeebackTypeLabel(), getIssueLabel()]) { response in
            switch response {
            case .success(let issue):
                if self.prefs.preferences.sourceControlGeneral.openFeedbackInBrowser {
                    self.openIssueURL(
                        issue.htmlURL
                        ?? URL("https://github.com/AuroraEditor/AuroraEditor/issues")
                    )
                }
                self.isSubmitted.toggle()
                self.logger.info("\(issue.number)")
            case .failure(let error):
                self.failedToSubmit.toggle()
                self.logger.fault("\(error)")
            }
        }
    }
}
