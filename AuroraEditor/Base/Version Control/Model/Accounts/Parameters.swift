//
//  Parameters.swift
//  Aurora Editor
//
//  Created by Nanashi Li on 2022/03/31.
//  Copyright © 2023 Aurora Company. All rights reserved.
//

import Foundation

public enum SortDirection: String {
    case asc
    case desc
}

public enum SortType: String {
    case created
    case updated
    case popularity
    case longRunning = "long-running"
}
