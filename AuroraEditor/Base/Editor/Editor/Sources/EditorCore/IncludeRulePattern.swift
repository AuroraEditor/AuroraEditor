//
//  IncludeRulePattern.swift
//  
//
//  Created by Matthew Davidson on 26/11/19.
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
        guard let pattern = repo.patterns[include] else {
            fatalError("""
                       Warning: Failed to resolve include rule with value: \(include) because the \
                       grammar '\(grammar.scopeName)' repository does not contain a pattern with name: '\(include)'.
                       """)
        }
        return pattern.resolve(parser: parser, grammar: grammar)
    }
}
