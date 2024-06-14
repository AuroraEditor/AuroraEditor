//
//  Repository.swift
//  Aurora Editor
//
//  Created by Matthew Davidson on 26/11/19.
//  Copyright © 2023 Aurora Company. All rights reserved.
//

import Foundation

// TODO: @0xWDG Look if this can be removed.
/// GIT Repository
public class Repository {
    /// Patterns
    var patterns: [String: Pattern]

    /// Initialize Repository
    /// 
    /// - Parameter patterns: Pattern
    public init(patterns: [String: Pattern]) {
        self.patterns = patterns
    }
}
