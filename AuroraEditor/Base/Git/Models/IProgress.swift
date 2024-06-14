//
//  IProgress.swift
//  Aurora Editor
//
//  Created by Nana on 3/10/21.
//  Copyright © 2023 Aurora Company. All rights reserved.
//
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
    /// The kind of operation being performed
    var kind: String { get }

    /// The branch that's currently being checked out
    var targetBranch: String { get }
}

/// An object describing the progression of a branch checkout operation
class CheckoutProgress: ICheckoutProgress {
    /// The kind of operation being performed
    var kind: String = "checkout"

    /// The branch that's currently being checked out
    var targetBranch: String

    /// Value of the progress
    var value: Int

    /// An informative text for user consumption indicating the current operation
    var title: String?

    /// An informative text for user consumption
    var description: String?

    /// Initialize a new `CheckoutProgress` instance.
    /// 
    /// - Parameter targetBranch: The branch that's currently being checked out.
    /// - Parameter value: Value of the progress.
    /// - Parameter title: An informative text for user consumption indicating the current operation.
    /// - Parameter description: An informative text for user consumption.
    /// 
    /// - Returns: A new `CheckoutProgress` instance.
    init(targetBranch: String, value: Int, title: String? = nil, description: String? = nil) {
        self.targetBranch = targetBranch
        self.value = value
        self.title = title
        self.description = description
    }
}

/// An object describing the progression of a fetch operation
protocol IFetchProgress: IProgress {
    /// The kind of operation being performed
    var kind: String { get }

    /// The remote that's being fetched
    var remote: String { get }
}

/// An object describing the progression of a fetch operation
class FetchProgress: IFetchProgress {
    /// The kind of operation being performed
    var kind: String = "fetch"

    /// The remote that's being fetched
    var remote: String

    /// Value of the progress
    var value: Int

    /// An informative text for user consumption indicating the current operation
    var title: String?

    /// An informative text for user consumption
    var description: String?

    /// Initialize a new `FetchProgress` instance.
    /// 
    /// - Parameter remote: The remote that's being fetched.
    /// - Parameter value: Value of the progress.
    /// - Parameter title: An informative text for user consumption indicating the current operation.
    /// - Parameter description: An informative text for user consumption.
    /// 
    /// - Returns: A new `FetchProgress` instance.
    init(remote: String, value: Int, title: String? = nil, description: String? = nil) {
        self.remote = remote
        self.value = value
        self.title = title
        self.description = description
    }
}

/// An object describing the progression of a pull operation
protocol IPullProgress: IProgress {
    /// The kind of operation being performed
    var kind: String { get }

    /// The remote that's being pulled from
    var remote: String { get }
}

/// An object describing the progression of a pull operation
class PullProgress: IPullProgress {
    /// The kind of operation being performed
    var kind: String = "pull"

    /// The remote that's being pulled from
    var remote: String

    /// Value of the progress
    var value: Int

    /// An informative text for user consumption indicating the current operation
    var title: String?

    /// An informative text for user consumption
    var description: String?

    /// Initialize a new `PullProgress` instance.
    /// 
    /// - Parameter remote: The remote that's being pulled from.
    /// - Parameter value: Value of the progress.
    /// - Parameter title: An informative text for user consumption indicating the current operation.
    /// - Parameter description: An informative text for user consumption.
    /// 
    /// - Returns: A new `PullProgress` instance.
    init(remote: String, value: Int, title: String? = nil, description: String? = nil) {
        self.remote = remote
        self.value = value
        self.title = title
        self.description = description
    }
}

/// An object describing the progression of a pull operation
protocol IPushProgress: IProgress {
    /// The kind of operation being performed
    var kind: String { get }

    /// The remote that's being pushed to
    var remote: String { get }

    /// The branch that's being pushed
    var branch: String { get }
}

/// An object describing the progression of a push operation
class PushProgress: IPushProgress {
    /// The kind of operation being performed
    var kind: String = "push"

    /// The remote that's being pushed to
    var remote: String

    /// The branch that's being pushed
    var branch: String

    /// Value of the progress
    var value: Int

    /// An informative text for user consumption indicating the current operation
    var title: String?

    /// An informative text for user consumption
    var description: String?

    /// Initialize a new `PushProgress` instance.
    /// 
    /// - Parameter remote: The remote that's being pushed to.
    /// - Parameter branch: The branch that's being pushed.
    /// - Parameter value: Value of the progress.
    /// - Parameter title: An informative text for user consumption indicating the current operation.
    /// - Parameter description: An informative text for user consumption.
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
    /// The kind of operation being performed
    var kind: String { get }
}

/// An object describing the progression of a fetch operation
class CloneProgress: ICloneProgress {
    /// The kind of operation being performed
    var kind: String = "clone"

    /// Value of the progress
    var value: Int

    /// An informative text for user consumption indicating the current operation
    var title: String?

    /// An informative text for user consumption
    var description: String?

    /// Initialize a new `CloneProgress` instance.
    /// 
    /// - Parameter value: Value of the progress.
    /// - Parameter title: An informative text for user consumption indicating the current operation.
    /// - Parameter description: An informative text for user consumption.
    ///
    /// - Returns: A new `CloneProgress` instance.
    init(value: Int, title: String? = nil, description: String? = nil) {
        self.value = value
        self.title = title
        self.description = description
    }
}

/// An object describing the progression of a revert operation.
protocol IRevertProgress: IProgress {
    /// The kind of operation being performed
    var kind: String { get }
}

/// An object describing the progression of a revert operation.
class RevertProgress: IRevertProgress {
    /// The kind of operation being performed
    var kind: String = "revert"

    /// Value of the progress
    var value: Int

    /// An informative text for user consumption indicating the current operation
    var title: String?

    /// An informative text for user consumption
    var description: String?

    /// Initialize a new `RevertProgress` instance.
    /// 
    /// - Parameter value: Value of the progress.
    /// - Parameter title: An informative text for user consumption indicating the current operation.
    /// - Parameter description: An informative text for user consumption.
    /// 
    /// - Returns: A new `RevertProgress` instance.
    init(value: Int, title: String? = nil, description: String? = nil) {
        self.value = value
        self.title = title
        self.description = description
    }
}

/// An object describing the progression multiple commit operations.
protocol IMultiCommitOperationProgress: IProgress {
    /// The kind of operation being performed
    var kind: String { get }

    /// The summary of the commit applied
    var currentCommitSummary: String { get }

    /// The number to signify which commit in a selection is being applied
    var position: Int { get }

    /// The total number of commits in the operation
    var totalCommitCount: Int { get }
}

/// An object describing the progression multiple commit operations.
class MultiCommitOperationProgress: IMultiCommitOperationProgress {
    /// The kind of operation being performed
    var kind: String = "multiCommitOperation"

    /// The summary of the commit applied
    var currentCommitSummary: String

    /// The number to signify which commit in a selection is being applied
    var position: Int

    /// The total number of commits in the operation
    var totalCommitCount: Int

    /// Value of the progress
    var value: Int

    /// An informative text for user consumption indicating the current operation
    var title: String?

    /// An informative text for user consumption
    var description: String?

    /// Initialize a new `MultiCommitOperationProgress` instance.
    /// 
    /// - Parameter currentCommitSummary: The summary of the commit applied.
    /// - Parameter position: The number to signify which commit in a selection is being applied.
    /// - Parameter totalCommitCount: The total number of commits in the operation.
    /// - Parameter value: Value of the progress.
    /// - Parameter title: An informative text for user consumption indicating the current operation.
    /// - Parameter description: An informative text for user consumption.
    /// 
    /// - Returns: A new `MultiCommitOperationProgress` instance.
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
