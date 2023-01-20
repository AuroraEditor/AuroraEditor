//
//  IProgress.swift
//  Aurora Editor
//
//  Created by Nanashi Li on 2022/08/13.
//  This source code is restricted for Aurora Editor usage only.
//

import Foundation

/// Base protocol containing all the properties that progress events
/// need to support.
protocol IProgress {
    /// The overall progress of the operation, represented as a fraction between
    /// 0 and 1.
    var value: Int { get }
    /// An informative text for user consumption indicating the current operation
    /// state. This will be high level such as 'Pushing origin' or
    /// 'Fetching upstream' and will typically persist over a number of progress
    /// events. For more detailed information about the progress see
    /// the description field
    var title: String? { get }
    /// An informative text for user consumption. In the case of git progress this
    /// will usually be the last raw line of output from git.
    var description: String? { get }
}

/// An object describing the progression of a branch checkout operation
protocol ICheckoutProgress: IProgress {
    var kind: String { get }
    /// The branch that's currently being checked out
    var targetBranch: String { get }
}

class CheckoutProgress: ICheckoutProgress {
    var kind: String = "checkout"
    var targetBranch: String
    var value: Int
    var title: String?
    var description: String?

    init(targetBranch: String, value: Int, title: String? = nil, description: String? = nil) {
        self.targetBranch = targetBranch
        self.value = value
        self.title = title
        self.description = description
    }
}

/// An object describing the progression of a fetch operation
protocol IFetchProgress: IProgress {
    var kind: String { get }
    /// The remote that's being fetched
    var remote: String { get }
}

class FetchProgress: IFetchProgress {
    var kind: String = "fetch"
    var remote: String
    var value: Int
    var title: String?
    var description: String?

    init(remote: String, value: Int, title: String? = nil, description: String? = nil) {
        self.remote = remote
        self.value = value
        self.title = title
        self.description = description
    }
}

/// An object describing the progression of a pull operation
protocol IPullProgress: IProgress {
    var kind: String { get }
    /// The remote that's being pulled from
    var remote: String { get }
}

class PullProgress: IPullProgress {
    var kind: String = "pull"
    var remote: String
    var value: Int
    var title: String?
    var description: String?

    init(remote: String, value: Int, title: String? = nil, description: String? = nil) {
        self.remote = remote
        self.value = value
        self.title = title
        self.description = description
    }
}

/// An object describing the progression of a pull operation
protocol IPushProgress: IProgress {
    var kind: String { get }
    /// The remote that's being pushed to
    var remote: String { get }
    /// The branch that's being pushed
    var branch: String { get }
}

class PushProgress: IPushProgress {
    var kind: String = "push"
    var remote: String
    var branch: String
    var value: Int
    var title: String?
    var description: String?

    init(remote: String, branch: String, value: Int, title: String? = nil, description: String? = nil) {
        self.remote = remote
        self.branch = branch
        self.value = value
        self.title = title
        self.description = description
    }
}

/// An object describing the progression of a fetch operation
protocol ICloneProgress: IProgress {
    var kind: String { get }
}

class CloneProgress: ICloneProgress {
    var kind: String = "clone"
    var value: Int
    var title: String?
    var description: String?

    init(value: Int, title: String? = nil, description: String? = nil) {
        self.value = value
        self.title = title
        self.description = description
    }
}

/// An object describing the progression of a revert operation.
protocol IRevertProgress: IProgress {
    var kind: String { get }
}

class RevertProgress: IRevertProgress {
    var kind: String = "revert"
    var value: Int
    var title: String?
    var description: String?

    init(value: Int, title: String? = nil, description: String? = nil) {
        self.value = value
        self.title = title
        self.description = description
    }
}

protocol IMultiCommitOperationProgress: IProgress {
    var kind: String { get }
    /// The summary of the commit applied
    var currentCommitSummary: String { get }
    /// The number to signify which commit in a selection is being applied
    var position: Int { get }
    /// The total number of commits in the operation
    var totalCommitCount: Int { get }
}

class MultiCommitOperationProgress: IMultiCommitOperationProgress {
    var kind: String = "multiCommitOperation"
    var currentCommitSummary: String
    var position: Int
    var totalCommitCount: Int
    var value: Int
    var title: String?
    var description: String?

    init(currentCommitSummary: String,
         position: Int,
         totalCommitCount: Int,
         value: Int,
         title: String? = nil,
         description: String? = nil) {
        self.currentCommitSummary = currentCommitSummary
        self.position = position
        self.totalCommitCount = totalCommitCount
        self.value = value
        self.title = title
        self.description = description
    }
}
