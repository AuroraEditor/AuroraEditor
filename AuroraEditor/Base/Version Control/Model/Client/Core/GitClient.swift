//
//  GitClient.swift
//  AuroraEditorModules/Git
//
//  Created by Marco Carnevali on 21/03/22.
//  Refactored by TAY KAI QUAN on 4 Sep 2022
//
import Foundation
import Combine
import Version_Control

// A protocol to make calls to terminal to init a git call.
public class GitClient: ObservableObject {
    var directoryURL: URL
    var shellClient: ShellClient

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
        _ = try? getGitBranches(allBranches: false)
        _ = try? getGitBranches(allBranches: true)
    }

    public var currentBranchName: AnyPublisher<String, Never>
    private var currentBranchNameSubject = CurrentValueSubject<String, Never>("Unknown Branch")
    @Published var publishedBranchName: String = ""

    public var branchNames: AnyPublisher<[String], Never>
    private var branchNamesSubject = CurrentValueSubject<[String], Never>([])
    @Published var publishedBranchNames: [String] = []

    public var allBranchNames: AnyPublisher<[String], Never>
    private var allBranchNamesSubject = CurrentValueSubject<[String], Never>([])
    @Published var publishedAllBranchNames: [String] = []

    public func getCurrentBranchName() throws -> String {
        let output = try shellClient.run(
            "cd \(directoryURL.relativePath.escapedWhiteSpaces());git rev-parse --abbrev-ref HEAD"
        )
            .replacingOccurrences(of: "\n", with: "")
        if output.contains("fatal: not a git repository") {
            throw GitClientError.notGitRepository
        }
        currentBranchNameSubject.send(output)
        publishedBranchName = output
        objectWillChange.send()
        return output
    }

    public func getGitBranches(allBranches: Bool = false) throws -> [String] {
        let branches = try getBranches(allBranches, directoryURL: directoryURL)
        if allBranches {
            allBranchNamesSubject.send(branches)
            publishedAllBranchNames = branches
        } else {
            branchNamesSubject.send(branches)
            publishedBranchNames = branches
        }
        objectWillChange.send()
        return branches
    }

    public func checkoutBranch(name: String) throws {
        guard currentBranchNameSubject.value != name else { return }
        let output = try shellClient.run(
            "cd \(directoryURL.relativePath.escapedWhiteSpaces());git checkout \(name)"
        )
        if output.contains("fatal: not a git repository") {
            throw GitClientError.notGitRepository
        } else if !output.contains("Switched to branch") && !output.contains("Switched to a new branch") {
            Log.error(output)
            throw GitClientError.outputError(output)
        }
        _ = try? getCurrentBranchName() // update the current branch
    }

    public func pull() throws {
        let output = try shellClient.run(
            "cd \(directoryURL.relativePath);git pull"
        )
        if output.contains("fatal: not a git repository") {
            throw GitClientError.notGitRepository
        }
    }

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

    /// Displays paths that have differences between the index file and the current HEAD commit,
    /// paths that have differences between the working tree and the index file, and paths in the working tree
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
    /// - Parameters:
    ///   - entries: number of commits we want to fetch. Will use max if nil
    ///   - fileLocalPath: specify a local file (e.g. `AuroraEditorModules/Package.swift`)
    ///   to retrieve a file commit history. Optional.
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

    public func discardFileChanges(url: String) throws {
        let output = try shellClient.run("cd \(directoryURL.relativePath.escapedWhiteSpaces());git restore \(url)")
        if output.contains("fatal") {
            throw GitClientError.outputError(output)
        } else {
            Log.info("Successfully disregarded changes!")
        }
    }

    public func discardProjectChanges() throws {
        let output = try shellClient.run("cd \(directoryURL.relativePath.escapedWhiteSpaces());git restore .")
        if output.contains("fatal") {
            throw GitClientError.outputError(output)
        } else {
            Log.info("Successfully disregarded changes!")
        }
    }

    public func stashChanges(message: String?) throws {
        if message == nil {
            let output = try shellClient.run("cd \(directoryURL.relativePath.escapedWhiteSpaces());git stash")
            if output.contains("fatal") {
                throw GitClientError.outputError(output)
            } else {
                Log.info("Successfully stashed changes!")
            }
        } else {
            let output = try shellClient.run(
                "cd \(directoryURL.relativePath.escapedWhiteSpaces());git stash save \(message!)"
            )
            if output.contains("fatal") {
                throw GitClientError.outputError(output)
            } else {
                Log.info("Successfully stashed changes!")
            }
        }
    }
}
