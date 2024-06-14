//
//  MatchRule.swift
//  Aurora Editor
//
//  Created by Matthew Davidson on 26/11/19.
//  Copyright © 2023 Aurora Company. All rights reserved.
//

import Foundation

// TODO: @0xWDG Look if this can be removed.
/// A rule that matches a pattern.
public class MatchRule: Rule, Pattern {
    /// The id of the rule.
    public let id: UUID

    /// The grammar that the rule belongs to.
    public weak var grammar: Grammar?

    /// Scope name of the rule.
    let scopeName: ScopeName

    /// The regex pattern to match.
    var match: NSRegularExpression

    /// The captures for the rule.
    var captures: [Capture]

    /// Creates a match rule.
    /// 
    /// - parameter name: The name of the rule.
    /// - parameter match: The regex pattern to match.
    /// - parameter captures: The captures for the rule.
    public init(
        name: String,
        match: String,
        captures: [Capture] = []
    ) {
        self.id = UUID()
        self.scopeName = ScopeName(rawValue: name)
        do {
            self.match = try NSRegularExpression(
                pattern: match,
                                                 options: .init(
                                                    arrayLiteral: .anchorsMatchLines,
                                                    .dotMatchesLineSeparators
                                                 )
            )
        } catch {
            var message = "Could not create regex for MatchRule "
            message += "name(\"\(name)\"), regex(\"\(match)\"), "
            message += "error: \"\(error.localizedDescription)\""

            Log.warning("\(message)")
            self.match = .init()
        }
        self.captures = captures
    }

    /// Resolves the match rule into rules.
    /// 
    /// - parameter parser: The parser to use for resolving patterns.
    /// - parameter grammar: The grammar to use for resolving patterns.
    /// 
    /// - returns: The resolved rules.
    public func resolve(parser: Parser, grammar: Grammar) -> [Rule] {
        self.grammar = grammar
        return [self]
    }
}
