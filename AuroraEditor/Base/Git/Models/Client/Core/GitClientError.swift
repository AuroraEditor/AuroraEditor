//
//  GitClientError.swift
//  AuroraEditor
//
//  Created by TAY KAI QUAN on 4/9/22.
//  Copyright © 2022 Aurora Company. All rights reserved.
//

import Foundation

extension GitClient {
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
        case cloningInto
        case countingProgress(Int)
        case compressingProgress(Int)
        case receivingProgress(Int)
        case resolvingProgress(Int)
        case other(String)
    }
}
