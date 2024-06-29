//
//  GitBranch.swift
//  Aurora Editor
//
//  Created by Nanashi Li on 2022/08/17.
//  Copyright © 2023 Aurora Company. All rights reserved.
//

import Foundation

/// Interface: The number of commits a revision range is ahead/behind.
protocol IAheadBehind {
    /// The number of commits ahead of the revision range.
    var ahead: Int { get }

    /// The number of commits behind the revision range.
    var behind: Int { get }
}

class AheadBehind: IAheadBehind {
    /// The number of commits ahead of the revision range.
    var ahead: Int

    /// The number of commits behind the revision range.
    var behind: Int

    /// Initialize a new `AheadBehind` instance.
    /// 
    /// - Parameter ahead: The number of commits ahead of the revision range.
    /// - Parameter behind: The number of commits behind the revision range.
    init(ahead: Int, behind: Int) {
        self.ahead = ahead
        self.behind = behind
    }
}
