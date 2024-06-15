//
//  GitClient.swift
//  Aurora Editor
//
//  Created by Marco Carnevali on 21/03/22.
//  Copyright © 2023 Aurora Company. All rights reserved.
//
//  Refactored by TAY KAI QUAN on 4 Sep 2022
//

import Foundation
import Combine
import Version_Control
import OSLog

// A protocol to make calls to terminal to init a git call.
public class GitClient: ObservableObject { // swiftlint:disable:this type_body_length

    /// Directory URL
    var directoryURL: URL

    /// Shell Client
    var shellClient: ShellClient

    /// The max number of recent branches to find.
    private var recentBranchesLimit = 5

    /// Pull with rebase
    @Published
    var pullWithRebase: Bool?

    /// All branches
    @Published
    public var allBranches: [GitBranch] = []

    /// Recent branches
    @Published
    var recentBranches: [GitBranch] = []

    /// Default branch
    @Published
    var defaultBranch: GitBranch?

    /// Upstream default branch
    @Published
    var upstreamDefaultBranch: GitBranch?

    /// Logger
    private let logger = Logger(subsystem: "com.auroraeditor", category: "version-control")

    /// Initialize Git Client
    /// 
    /// - Parameter directoryURL: Directory URL
    /// - Parameter shellClient: Shell Client
    /// 
    /// - Returns: Git Client
    init(directoryURL: URL, shellClient: ShellClient) {
        self.directoryURL = directoryURL
        self.shellClient = shellClient

        self.currentBranchName = currentBranchNameSubject
            .receive(on: RunLoop.main)
            .eraseToAnyPublisher()

        self.branchNames = branchNamesSubject
            .receive(on: RunLoop.main)
            .eraseToAnyPublisher()

        self.allBranchNames = allBranchNamesSubject
            .receive(on: RunLoop.main)
            .eraseToAnyPublisher()

        _ = try? getCurrentBranchName()
        loadBranches()
    }

    /// Current branch name
    public var currentBranchName: AnyPublisher<String, Never>

    /// Current branch name subject
    private var currentBranchNameSubject = CurrentValueSubject<String, Never>("Unknown Branch")

    /// Published branch name
    @Published var publishedBranchName: String?

    /// Branch names
    public var branchNames: AnyPublisher<[String], Never>

    /// Branch names subject
    private var branchNamesSubject = CurrentValueSubject<[String], Never>([])

    /// Published branch names
    @Published var publishedBranchNames: [String] = []

    /// All branch names
    public var allBranchNames: AnyPublisher<[String], Never>

    /// All branch names subject
    private var allBranchNamesSubject = CurrentValueSubject<[String], Never>([])

    /// Published all branch names
    @Published var publishedAllBranchNames: [String] = []

    /// Get current branch name
    /// 
    /// - Returns: Branch name
    /// 
    /// - Throws: GitClientError
    public func getCurrentBranchName() throws -> String {
        let result = try GitShell().git(args: ["rev-parse", "--abbrev-ref", "HEAD"],
                                        path: directoryURL,
                                        name: #function)

        if result.stdout.contains("fatal: not a git repository") {
            throw GitClientError.notGitRepository
        }
        currentBranchNameSubject.send(result.stdout.replacingOccurrences(of: "\n", with: ""))
        publishedBranchName = result.stdout.replacingOccurrences(of: "\n", with: "")
        objectWillChange.send()
        return result.stdout.replacingOccurrences(of: "\n", with: "")
    }

    // MARK: - BRANCHES

    /// Load branches
    public func loadBranches() {
        let localAndRemoteBranches = try? Branch().getBranches(directoryURL: directoryURL)

        // Chances are that the recent branches list will contain the default
        // branch which we filter out in refreshRecentBranches. So grab one
        // more than we need to account for that.
        let recentBranchNames = try? Branch().getRecentBranches(directoryURL: directoryURL,
                                                                limit: recentBranchesLimit + 1)

        guard let localAndRemoteBranches = localAndRemoteBranches else {
            return
        }

        self.allBranches = BranchUtil().mergeRemoteAndLocalBranches(branches: localAndRemoteBranches)

        // refreshRecentBranches is dependent on having a default branch
        self.refreshDefaultBranch()
        self.refreshRecentBranches(recentBranchNames: recentBranchNames)

        self.checkPullWithRebase()
    }

    /// Refresh default branch
    public func refreshDefaultBranch() {
        do {
            defaultBranch = try DefaultBranch().findDefaultBranch(directoryURL: directoryURL,
                                                                  branches: allBranches,
                                                                  defaultRemoteName: "")

            let upstreamDefaultBranch = try Remote().getRemoteHEAD(directoryURL: directoryURL,
                                                                   remote: "") ?? DefaultBranch().getDefaultBranch()

            self.upstreamDefaultBranch = self.allBranches.first { branch in
                return branch.type == .remote &&
                branch.remoteName == "fewf" &&
                branch.nameWithoutRemote == upstreamDefaultBranch
            } ?? nil
        } catch {
            // Handle errors appropriately
        }
    }

    /// Refresh recent branches
    private func refreshRecentBranches(recentBranchNames: [String]?) {
        guard let recentBranchNames = recentBranchNames, !recentBranchNames.isEmpty else {
            self.recentBranches = []
            return
        }

        var branchesByName = [String: GitBranch]()

        for branch in self.allBranches where branch.type == .local {
            branchesByName[branch.name] = branch
        }

        var recentBranches = [GitBranch]()
        for name in recentBranchNames {
            if name == self.defaultBranch?.name {
                continue
            }

            if let branch = branchesByName[name] {
                recentBranches.append(branch)
            }
            if recentBranches.count >= recentBranchesLimit {
                break
            }
        }

        self.recentBranches = recentBranches
    }

    /// Get branch names
    /// 
    /// - Returns: Branch names
    /// 
    /// - Throws: GitClientError
    public func checkoutBranch(name: String) throws {
        guard currentBranchNameSubject.value != name else { return }
        let output = try shellClient.run(
            "cd \(directoryURL.relativePath.escapedWhiteSpaces());" +
            "git checkout \(name)"
        )
        if output.contains("fatal: not a git repository") {
            throw GitClientError.notGitRepository
        } else if !output.contains("Switched to branch") && !output.contains("Switched to a new branch") {
            throw GitClientError.outputError(output)
        }
        _ = try? getCurrentBranchName() // update the current branch
    }

    // MARK: - PULL

    /// Pull
    /// 
    /// - Throws: GitClientError
    public func pull() throws {
        let output = try shellClient.run(
            "cd \(directoryURL.relativePath);git pull"
        )
        if output.contains("fatal: not a git repository") {
            throw GitClientError.notGitRepository
        }
    }

    /// Pull with rebase
    /// 
    /// - Throws: GitClientError
    private func checkPullWithRebase() {
        do {
            if let result = try Config().getConfigValue(directoryURL: directoryURL,
                                                        name: "pull.rebase") {
                switch result {
                case "":
                    self.pullWithRebase = nil
                case "true":
                    self.pullWithRebase = true
                case "false":
                    self.pullWithRebase = false
                default:
                    Log.warning("Unexpected value found for pull.rebase in config: '\(result)'")
                    // Ensure any previous value is purged from app state
                    self.pullWithRebase = nil
                }
            }
        } catch {

        }
    }

    /// Pull with rebase
    /// 
    /// - Parameter path: Path
    /// - Parameter branch: Branch
    /// - Parameter allBranches: All Branches
    /// 
    /// - Returns: AnyPublisher<CloneProgressResult, GitClientError>
    public func cloneRepository(path: String, branch: String, allBranches: Bool) ->
    AnyPublisher<CloneProgressResult, GitClientError> {
        let command = allBranches ?
        // swiftlint:disable:next line_length
        "git clone \(path) \(directoryURL.relativePath.escapedWhiteSpaces()) --progress && cd \(directoryURL.relativePath.escapedWhiteSpaces()) && git checkout \(branch)" :
        "git clone -b \(branch) --single-branch \(path) \(directoryURL.relativePath.escapedWhiteSpaces()) --progress"
        return shellClient
            .runLive(command).tryMap { output -> String in
                if output.contains("fatal: not a git repository") {
                    throw GitClientError.notGitRepository
                }
                return output
            }
            .map { value -> CloneProgressResult in
                return self.valueToProgress(value: value)
            }
            .mapError {
                if let error = $0 as? GitClientError {
                    return error
                } else {
                    return GitClientError.outputError($0.localizedDescription)
                }
            }
            .eraseToAnyPublisher()
    }

    /// Value to progress
    /// 
    /// - Parameter value: Value
    /// 
    /// - Returns: CloneProgressResult
    private func valueToProgress(value: String) -> CloneProgressResult {
        // TODO: Make a more solid parsing system.
        if value.contains("Cloning into") {
            return .cloningInto
        } else if value.contains("Counting objects: ") {
            return .countingProgress(
                Int(
                    value
                        .replacingOccurrences(of: "remote: Counting objects: ", with: "")
                        .replacingOccurrences(of: " ", with: "")
                        .split(separator: "%")
                        .first ?? "0"
                ) ?? 0
            )
        } else if value.contains("Compressing objects: ") {
            return .compressingProgress(
                Int(
                    value
                        .replacingOccurrences(of: "remote: Compressing objects: ", with: "")
                        .replacingOccurrences(of: " ", with: "")
                        .split(separator: "%")
                        .first ?? "0"
                ) ?? 0
            )
        } else if value.contains("Receiving objects: ") {
            return .receivingProgress(
                Int(
                    value
                        .replacingOccurrences(of: "Receiving objects: ", with: "")
                        .replacingOccurrences(of: " ", with: "")
                        .split(separator: "%")
                        .first ?? "0"
                ) ?? 0
            )
        } else if value.contains("Resolving deltas: ") {
            return .resolvingProgress(
                Int(
                    value
                        .replacingOccurrences(of: "Resolving deltas: ", with: "")
                        .replacingOccurrences(of: " ", with: "")
                        .split(separator: "%")
                        .first ?? "0"
                ) ?? 0
            )
        } else {
            return .other(value)
        }
    }

    /// Get changed files
    /// 
    /// Displays paths that have differences between the index file and the current HEAD commit,
    /// paths that have differences between the working tree and the index file, and paths in the working tree
    /// 
    /// - Returns: Changed files
    /// 
    /// - Throws: GitClientError
    public func getChangedFiles() throws -> [FileItem] {
        let output = try shellClient.run(
            "cd \(directoryURL.relativePath.escapedWhiteSpaces());git status -s --porcelain -u"
        )
        if output.contains("fatal: not a git repository") {
            throw GitClientError.notGitRepository
        }
        return try output
            .split(whereSeparator: \.isNewline)
            .map { line -> FileItem in
                let paramData = line.trimmingCharacters(in: .whitespacesAndNewlines)
                let parameters = paramData.components(separatedBy: " ")
                let fileName = parameters[safe: 1] ?? String(describing: URLError.badURL)
                guard let url = URL(string: "file://\(directoryURL.relativePath)/\(fileName)") else {
                    throw GitClientError.failedToDecodeURL
                }

                var gitType: GitType {
                    .init(rawValue: parameters[safe: 0] ?? "") ?? GitType.unknown
                }

                return FileItem(url: url, changeType: gitType)
            }
    }

    /// Get commit history
    /// 
    /// - Parameters:
    ///   - entries: number of commits we want to fetch. Will use max if nil
    ///   - fileLocalPath: specify a local file (e.g. `AuroraEditorModules/Package.swift`)
    ///   to retrieve a file commit history. Optional.
    /// 
    /// - Returns: Commit history
    /// 
    /// - Throws: GitClientError
    public func getCommitHistory(entries: Int?, fileLocalPath: String?) throws -> [CommitHistory] {
        var entriesString = ""
        let fileLocalPath = fileLocalPath?.escapedWhiteSpaces() ?? ""
        if let entries = entries { entriesString = "-n \(entries)" }
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale.current
        dateFormatter.dateFormat = "EEE, dd MMM yyyy HH:mm:ss Z"
        let output = try shellClient.run(
            // swiftlint:disable:next line_length
            "cd \(directoryURL.relativePath.escapedWhiteSpaces());git log --follow --pretty=%h¦%H¦%s¦%aN¦%ae¦%cn¦%ce¦%aD¦ \(entriesString) \(fileLocalPath)"
        )
        let remote = try shellClient.run(
            "cd \(directoryURL.relativePath.escapedWhiteSpaces());git ls-remote --get-url"
        )
        let remoteURL = URL(string: remote.trimmingCharacters(in: .whitespacesAndNewlines))
        if output.contains("fatal: not a git repository") {
            throw GitClientError.notGitRepository
        }
        return output
            .split(separator: "\n")
            .map { line -> CommitHistory in
                let parameters = line.components(separatedBy: "¦")
                return CommitHistory(
                    hash: parameters[safe: 0] ?? "",
                    commitHash: parameters[safe: 1] ?? "",
                    message: parameters[safe: 2] ?? "",
                    author: parameters[safe: 3] ?? "",
                    authorEmail: parameters[safe: 4] ?? "",
                    commiter: parameters[safe: 5] ?? "",
                    commiterEmail: parameters[safe: 6] ?? "",
                    remoteURL: remoteURL,
                    date: dateFormatter.date(from: parameters[safe: 7] ?? "") ?? Date(),
                    isMerge: nil
                )
            }
    }

    /// Discard file changes
    /// 
    /// - Parameter url: URL
    /// 
    /// - Throws: GitClientError
    public func discardFileChanges(url: String) throws {
        let output = try shellClient.run("cd \(directoryURL.relativePath.escapedWhiteSpaces());git restore \(url)")
        if output.contains("fatal") {
            throw GitClientError.outputError(output)
        } else {
            logger.info("Successfully disregarded changes!")
        }
    }

    /// Discard project changes
    /// 
    /// - Throws: GitClientError
    public func discardProjectChanges() throws {
        let output = try shellClient.run("cd \(directoryURL.relativePath.escapedWhiteSpaces());git restore .")
        if output.contains("fatal") {
            throw GitClientError.outputError(output)
        } else {
            logger.info("Successfully disregarded changes!")
        }
    }

    /// Stash changes
    /// 
    /// - Parameter message: Message
    /// 
    /// - Throws: GitClientError
    public func stashChanges(message: String?) throws {
        if message == nil {
            let output = try shellClient.run("cd \(directoryURL.relativePath.escapedWhiteSpaces());git stash")
            if output.contains("fatal") {
                throw GitClientError.outputError(output)
            } else {
                logger.info("Successfully stashed changes!")
            }
        } else {
            let output = try shellClient.run(
                "cd \(directoryURL.relativePath.escapedWhiteSpaces());git stash save \(message!)"
            )
            if output.contains("fatal") {
                throw GitClientError.outputError(output)
            } else {
                logger.info("Successfully stashed changes!")
            }
        }
    }

    /// Stage files
    /// 
    /// - Parameter files: Files
    /// 
    /// - Throws: GitClientError
    public func stage(files: [String]) throws {
        let output = try shellClient.run(
            "cd \(directoryURL.relativePath.escapedWhiteSpaces());git add \(files.joined(separator: " "))"
        )
        if output.contains("fatal") {
            throw GitClientError.outputError(output)
        } else {
            logger.info("Successfully staged files: \(files.joined(separator: ", "))")
        }
    }

    /// Unstage files
    /// 
    /// - Parameter files: Files
    /// 
    /// - Throws: GitClientError
    public func unstage(files: [String]) throws {
        let output = try shellClient.run(
            "cd \(directoryURL.relativePath.escapedWhiteSpaces());" +
            "git restore --staged \(files.joined(separator: " "))"
        )
        if output.contains("fatal") {
            throw GitClientError.outputError(output)
        } else {
            logger.info("Successfully unstaged files: \(files.joined(separator: ", "))")
        }
    }

    /// Commit
    /// 
    /// - Parameter message: Message
    /// 
    /// - Throws: GitClientError
    public func commit(message: String) throws {
        let output = try shellClient.run(
            "cd \(directoryURL.relativePath.escapedWhiteSpaces());" +
            "git commit -m '\(message.escapedQuotes())'"
        )
        if output.contains("fatal") {
            throw GitClientError.outputError(output)
        } else {
            logger.info("Successfully commited with message \"\(message)\"")
        }
    }
}
// swiftlint:disable:this file_length
