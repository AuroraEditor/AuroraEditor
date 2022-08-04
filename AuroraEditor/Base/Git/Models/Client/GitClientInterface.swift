//
//  GitClientInterface.swift
//  AuroraEditorModules/Git
//
//  Created by Marco Carnevali on 21/03/22.
//
import Foundation
import Combine

// TODO: DOCS (Marco Carnevali)
public struct GitClient {
    public var getCurrentBranchName: () throws -> String
    public var getBranches: (Bool) throws -> [String]
    public var checkoutBranch: (String) throws -> Void
    public var pull: () throws -> Void
    public var cloneRepository: (String) -> AnyPublisher<CloneProgressResult, GitClientError>
    /// Displays paths that have differences between the index file and the current HEAD commit,
    /// paths that have differences between the working tree and the index file, and paths in the working tree
    public var getChangedFiles: () throws -> [ChangedFile]
    /// Get commit history
    /// - Parameters:
    ///   - entries: number of commits we want to fetch. Will use max if nil
    ///   - fileLocalPath: specify a local file (e.g. `AuroraEditorModules/Package.swift`)
    ///   to retrieve a file commit history. Optional.
    public var getCommitHistory: (_ entries: Int?, _ fileLocalPath: String?) throws -> [Commit]
    public var discardFileChanges: (String) throws -> Void
    public var discardProjectChanges: () throws -> Void
    public var stashChanges: (String) throws -> Void

    init(
        getCurrentBranchName: @escaping () throws -> String,
        getBranches: @escaping (Bool) throws -> [String],
        checkoutBranch: @escaping (String) throws -> Void,
        pull: @escaping () throws -> Void,
        cloneRepository: @escaping (String) -> AnyPublisher<CloneProgressResult, GitClientError>,
        getChangedFiles: @escaping () throws -> [ChangedFile],
        getCommitHistory: @escaping (_ entries: Int?, _ fileLocalPath: String?) throws -> [Commit],
        discardFileChanges: @escaping (String) throws -> Void,
        discardProjectChanges: @escaping () throws -> Void,
        stashChanges: @escaping (String) throws -> Void
    ) {
        self.getCurrentBranchName = getCurrentBranchName
        self.getBranches = getBranches
        self.checkoutBranch = checkoutBranch
        self.pull = pull
        self.cloneRepository = cloneRepository
        self.getChangedFiles = getChangedFiles
        self.getCommitHistory = getCommitHistory
        self.discardFileChanges = discardFileChanges
        self.discardProjectChanges = discardProjectChanges
        self.stashChanges = stashChanges
    }

    public enum GitClientError: Error {
        case badConfigFile
        case authenticationFailed
        case noUserNameConfigured
        case noUserEmailConfigured
        case notAGitRepository
        case notAtRepositoryRoot
        case conflict
        case stashConflict
        case unmergedChanges
        case pushRejected
        case remoteConnectionError
        case dirtyWorkTree
        case cantOpenResource
        case gitNotFound
        case cantCreatePipe
        case cantAccessRemote
        case repositoryNotFound
        case repositoryIsLocked
        case branchNotFullyMerged
        case noRemoteReference
        case invalidBranchName
        case branchAlreadyExists
        case noLocalChanges
        case noStashFound
        case localChangesOverwritten
        case noUpstreamBranch
        case isInSubModule
        case wrongCase
        case cantLockRef
        case cantRebaseMultipleBranches
        case patchDoesNotApply
        case outputError(String)
        case notGitRepository
        case failedToDecodeURL
    }

    public enum CloneProgressResult {
        case receivingProgress(Int)
        case resolvingProgress(Int)
        case other(String)
    }
}
