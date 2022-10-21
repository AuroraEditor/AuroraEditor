//
//  Repository.swift
//
//
//  Created by Matthew Davidson on 26/11/19.
//

import Foundation

public class Repository {

    var patterns: [String: Pattern]

    public init(patterns: [String: Pattern]) {
        self.patterns = patterns
    }
}
