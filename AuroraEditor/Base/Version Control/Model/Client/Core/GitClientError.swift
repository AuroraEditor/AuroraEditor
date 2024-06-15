//
//  GitClientError.swift
//  Aurora Editor
//
//  Created by TAY KAI QUAN on 4/9/22.
//  Copyright © 2023 Aurora Company. All rights reserved.
//

import Foundation

/// Git Client
extension GitClient {

    /// Git Client Error
    public enum GitClientError: Error {

        /// Bad Configuration File
        case badConfigFile

        /// Invalid Configuration Value
        case authenticationFailed

        /// No User Name Configured
        case noUserNameConfigured

        /// No User Email Configured
        case noUserEmailConfigured

        /// Not A Git Repository
        case notAGitRepository

        /// Not At Repository Root
        case notAtRepositoryRoot

        /// Merge Conflict
        case conflict

        /// Stash Conflict
        case stashConflict

        /// Unmerged changes
        case unmergedChanges

        /// Push Rejected
        case pushRejected

        /// Remote Connection Error
        case remoteConnectionError

        /// Dirty Work Tree
        case dirtyWorkTree

        /// Cant Open Resource
        case cantOpenResource

        /// Git Not Found
        case gitNotFound

        /// Cant Create Pipe
        case cantCreatePipe

        /// Cant access Remote
        case cantAccessRemote

        /// Repository Not Found
        case repositoryNotFound

        /// Repository Is Locked
        case repositoryIsLocked

        /// Branch Not Fully Merged
        case branchNotFullyMerged

        /// No Remote Reference
        case noRemoteReference

        /// Invalid Branch Name
        case invalidBranchName

        /// Branch Already Exists
        case branchAlreadyExists

        /// No Local Changes
        case noLocalChanges

        /// No Stash Found
        case noStashFound

        /// Local Changes Overwritten
        case localChangesOverwritten

        /// No Upstream Branch
        case noUpstreamBranch

        /// Is In Sub Module
        case isInSubModule

        /// Wrong Case
        case wrongCase

        /// Cant Lock Reference
        case cantLockRef

        /// Cant Rebase Multiple Branches
        case cantRebaseMultipleBranches

        /// Patch Does Not Apply
        case patchDoesNotApply

        /// Output Error
        /// 
        /// - Parameter Error: String
        case outputError(String)

        /// Not a git repository
        case notGitRepository

        /// Failed to decode URL
        case failedToDecodeURL
    }

    /// Clone progress result
    public enum CloneProgressResult {
        /// Cloning in to
        case cloningInto

        /// Counting progress
        case countingProgress(Int)

        /// Compressing progress
        case compressingProgress(Int)

        /// Receiving progress
        case receivingProgress(Int)

        /// Resolving progress
        case resolvingProgress(Int)

        /// Other
        case other(String)
    }
}
