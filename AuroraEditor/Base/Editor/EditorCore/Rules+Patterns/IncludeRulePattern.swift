//
//  IncludeRulePattern.swift
//  Aurora Editor
//
//  Created by Matthew Davidson on 26/11/19.
//  Copyright © 2023 Aurora Company. All rights reserved.
//

import Foundation

// TODO: @0xWDG Look if this can be removed.
/// A pattern that includes other patterns.
public class IncludeRulePattern: Pattern {
    /// The name of the pattern to include.
    var include: String

    /// Includes a pattern identified by its name.
    /// 
    /// - Parameter include: The name of the pattern to include.
    public init(include: String) {
        self.include = include
    }

    /// Resolves the include pattern into rules.
    /// 
    /// - parameter parser: The parser to use for resolving patterns.
    /// - parameter grammar: The grammar to use for resolving patterns.
    /// 
    /// - returns: The resolved rules.
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
