//
//  Repository.swift
//  Aurora Editor
//
//  Created by Matthew Davidson on 26/11/19.
//  Copyright © 2023 Aurora Company. All rights reserved.
//

import Foundation

/// GIT Repository
public class Repository {

    var patterns: [String: Pattern]

    /// Initialize Repository
    /// - Parameter patterns: Pattern
    public init(patterns: [String: Pattern]) {
        self.patterns = patterns
    }
}
