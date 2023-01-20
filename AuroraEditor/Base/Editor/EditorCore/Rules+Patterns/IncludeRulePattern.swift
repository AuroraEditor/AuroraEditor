//
//  IncludeRulePattern.swift
//  Aurora Editor
//
//  Created by Matthew Davidson on 26/11/19.
//  Copyright © 2023 Aurora Company. All rights reserved.
//

import Foundation

public class IncludeRulePattern: Pattern {

    var include: String

    public init(include: String) {
        self.include = include
    }

    public func resolve(parser: Parser, grammar: Grammar) -> [Rule] {
        guard let repo = grammar.repository else {
            fatalError("""
                       Warning: Failed to resolve include rule with value: \(include) because the \
                       grammar '\(grammar.scopeName)' repository is nil.
                       """)
        }
        if include == "$self" {
            return grammar.rules // referencing the grammar itself, meaning everything
        }
        guard include.hasPrefix("#"), let pattern = repo.patterns[String(include.dropFirst())] else {
            fatalError("""
                       Warning: Failed to resolve include rule with value: \(include) because the \
                       grammar '\(grammar.scopeName)' repository does not contain a pattern with name: '\(include)'.
                       """)
        }
        return pattern.resolve(parser: parser, grammar: grammar)
    }
}
