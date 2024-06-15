//
//  Parameters.swift
//  Aurora Editor
//
//  Created by Nanashi Li on 2022/03/31.
//  Copyright © 2023 Aurora Company. All rights reserved.
//

import Foundation

/// Sort direction
public enum SortDirection: String {

    /// Ascending
    case asc

    /// Descending
    case desc
}

/// Sort type
public enum SortType: String {

    /// Created
    case created

    /// Updated
    case updated

    /// Popularity
    case popularity

    /// Long running
    case longRunning = "long-running"
}
