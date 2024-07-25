//
//  RepoRulesParser.swift
//  Aurora Editor
//
//  Created by Nanashi Li on 2024/07/20.
//  Copyright © 2024 Aurora Company. All rights reserved.
//

import Version_Control
import Foundation

/// `RepoRulesParser` is responsible for parsing repository rules fetched from
/// GitHub API responses. It converts raw API data into a structured and usable format
/// encapsulated by the `RepoRulesInfo` structure.
struct RepoRulesParser {

    /// Returns whether repo rules could potentially exist for the provided account and repository.
    /// This only performs client-side checks, such as whether the user is on a free plan
    /// and the repo is public.
    public func useRepoRulesLogic(versionControl: VersionControlModel) -> Bool {
        if versionControl.workspaceProvider != .github {
            return false
        }

        // TODO: We need to check the users plan, login and if the repo is private
        return true
    }

    /// Parses the given repository rules and their associated rulesets into a `RepoRulesInfo` object.
    ///
    /// - Parameters:
    ///   - rules: An array of `IAPIRepoRule` objects representing the rules fetched from the API.
    ///   - rulesets: A dictionary mapping ruleset IDs to `IAPIRepoRuleset` objects.
    ///   - workspaceURL: The URL of the current workspace.
    /// - Returns: A `RepoRulesInfo` object containing parsed and structured rule information.
    func parseRepoRules(
        rules: [IAPIRepoRule],
        rulesets: [Int: IAPIRepoRuleset],
        workspaceURL: URL
    ) -> RepoRulesInfo {
        var info = RepoRulesInfo()
        let gpgSignEnabled = checkGPGSignEnabled(workspaceURL: workspaceURL)

        for rule in rules {
            guard let ruleset = rulesets[rule.ruleset_id] else { continue }

            let enforced: RepoRuleEnforced = (ruleset.current_user_can_bypass == .always) ? .bypass : .enforced(true)

            switch rule.type {
            case .update, .required_deployments, .required_status_checks:
                info.basicCommitWarning = max(info.basicCommitWarning, enforced)
            case .creation:
                info.creationRestricted = max(info.creationRestricted, enforced)
            case .required_signatures:
                if !gpgSignEnabled {
                    info.signedCommitsRequired = max(info.signedCommitsRequired, enforced)
                }
            case .pull_request:
                info.pullRequestRequired = max(info.pullRequestRequired, enforced)
            case .commit_message_pattern:
                if let metadataRule = toMetadataRule(rule: rule, enforced: enforced) {
                    info.commitMessagePatterns.push(metadataRule)
                }
            case .commit_author_email_pattern:
                if let metadataRule = toMetadataRule(rule: rule, enforced: enforced) {
                    info.commitAuthorEmailPatterns.push(metadataRule)
                }
            case .committer_email_pattern:
                if let metadataRule = toMetadataRule(rule: rule, enforced: enforced) {
                    info.committerEmailPatterns.push(metadataRule)
                }
            case .branch_name_pattern:
                if let metadataRule = toMetadataRule(rule: rule, enforced: enforced) {
                    info.branchNamePatterns.push(metadataRule)
                }
            default:
                return info
            }
        }

        return info
    }

    /// Asynchronously checks if GPG signing is enabled for git commits.
    ///
    /// This function attempts to retrieve the global git configuration value for "commit.gpgsign".
    /// It uses an asynchronous approach to avoid blocking the main thread during the check.
    ///
    /// - Parameter workspaceURL: The URL of the current workspace.
    ///   Note: This parameter is currently unused in the function body.
    ///
    /// - Returns: A boolean value indicating whether GPG signing is enabled.
    ///   Returns `true` if GPG signing is enabled, `false` otherwise or if an error occurs.
    ///
    /// - Note: This function uses `withCheckedThrowingContinuation` to bridge between
    ///   the asynchronous world and the synchronous world of the `Config` operations.
    func checkGPGSignEnabled(workspaceURL: URL) -> Bool {
        let config = Config()
        do {
            return try config.getGlobalBooleanConfigValue(
                path: workspaceURL,
                name: "commit.gpgsign"
            ) ?? false
        } catch {
            return false
        }
    }

    /// Converts a given `IAPIRepoRule` into an `IRepoRulesMetadataRule`.
    ///
    /// - Parameters:
    ///   - rule: The `IAPIRepoRule` to be converted.
    ///   - enforced: The enforcement status of the rule.
    /// - Returns: An `IRepoRulesMetadataRule` if the rule contains parameters, otherwise `nil`.
    func toMetadataRule(
        rule: IAPIRepoRule,
        enforced: RepoRuleEnforced
    ) -> IRepoRulesMetadataRule? {
        guard let parameters = rule.parameters else { return nil }

        return IRepoRulesMetadataRule(
            enforced: enforced,
            matcher: toMatcher(parameters),
            humanDescription: toHumanDescription(parameters),
            rulesetId: rule.ruleset_id
        )
    }

    /// Generates a human-readable description for the given rule parameters.
    ///
    /// - Parameter apiParams: The `IAPIRepoRuleMetadataParameters` containing rule details.
    /// - Returns: A string describing the rule in a human-readable format.
    func toHumanDescription(_ apiParams: IAPIRepoRuleMetadataParameters) -> String {
        let negation = apiParams.negate ?? false ? "not " : ""
        let action: String

        switch apiParams.operator {
        case .regex:
            return "must \(negation)match the regular expression \"\(apiParams.pattern)\""
        case .startsWith:
            action = "start with "
        case .endsWith:
            action = "end with "
        case .contains:
            action = "contain "
        default:
            action = ""
        }

        return "must \(negation)\(action)\"\(apiParams.pattern)\""
    }

    /// Converts rule parameters into a matcher function using regular expressions.
    ///
    /// - Parameter rule: The `IAPIRepoRuleMetadataParameters` containing rule details.
    /// - Returns: A `RepoRulesMetadataMatcher` function that evaluates whether a given string matches the rule.
    func toMatcher(_ rule: IAPIRepoRuleMetadataParameters) -> RepoRulesMetadataMatcher {
        let pattern: String
        switch rule.operator {
        case .startsWith:
            pattern = "^\(NSRegularExpression.escapedPattern(for: rule.pattern ?? ""))"
        case .endsWith:
            pattern = "\(NSRegularExpression.escapedPattern(for: rule.pattern ?? ""))$"
        case .contains:
            pattern = ".*\(NSRegularExpression.escapedPattern(for: rule.pattern ?? "")).*"
        case .regex:
            pattern = rule.pattern ?? ""
        default:
            pattern = ""
        }

        guard let regex = try? NSRegularExpression(pattern: pattern) else {
            return { _ in false }
        }

        return { toMatch in
            let range = NSRange(location: 0, length: toMatch.utf16.count)
            let matches = regex.firstMatch(in: toMatch, options: [], range: range) != nil
            return rule.negate ?? false ? !matches : matches
        }
    }

    /// Determines the stricter of two `RepoRuleEnforced` values.
    ///
    /// This function compares two `RepoRuleEnforced` values and returns the stricter one.
    /// The order of strictness from most to least strict is:
    /// 1. `.enforced(true)`
    /// 2. `.bypass`
    /// 3. `.enforced(false)`
    ///
    /// - Parameters:
    ///   - lhs: The left-hand side `RepoRuleEnforced` value to compare.
    ///   - rhs: The right-hand side `RepoRuleEnforced` value to compare.
    ///
    /// - Returns: The stricter of the two input `RepoRuleEnforced` values.
    ///
    /// - Note: This function is useful for consolidating multiple rule enforcements
    ///   into a single, most restrictive enforcement.
    func max(_ lhs: RepoRuleEnforced, _ rhs: RepoRuleEnforced) -> RepoRuleEnforced {
        switch (lhs, rhs) {
        case (.enforced(true), _), (_, .enforced(true)):
            return .enforced(true)
        case (.bypass, _), (_, .bypass):
            return .bypass
        default:
            return .enforced(false)
        }
    }
}
