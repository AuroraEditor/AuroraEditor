//
//  Openness.swift
//  Aurora Editor
//
//  Created by Nanshi Li on 2022/03/31.
//  Copyright © 2023 Aurora Company. All rights reserved.
//

import Foundation

@available(*, deprecated, renamed: "VersionControl", message: "This will be deprecated in favor of the new VersionControl Remote SDK APIs.")
/// Github issue/pull request state
public enum Openness: String, Codable {

    /// Open
    case open

    /// Closed
    case closed

    /// All
    case all
}
