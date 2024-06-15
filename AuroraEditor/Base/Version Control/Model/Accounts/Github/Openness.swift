//
//  Openness.swift
//  Aurora Editor
//
//  Created by Nanshi Li on 2022/03/31.
//  Copyright © 2023 Aurora Company. All rights reserved.
//

import Foundation

/// Github issue/pull request state
public enum Openness: String, Codable {

    /// Open
    case open

    /// Closed
    case closed

    /// All
    case all
}
