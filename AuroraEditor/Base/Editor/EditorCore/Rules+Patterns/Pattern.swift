//
//  Pattern.swift
//  Aurora Editor
//
//  Created by Matthew Davidson on 28/11/19.
//

import Foundation

///
/// Represents a defined pattern in a grammar.
///
/// The pattern represents one of the following rules:
/// - Match rule
/// - Begin/end rule
/// - Include rule
///
/// Acts as a definition of a rule which will be created when necessary.
///
public protocol Pattern {

    ///
    /// Resolves the rule that this pattern represents.
    ///
    /// For `MatchRule`s  and `BeginEndRule`s  rules, it is as simple as returning the object as the
    /// definition of the pattern itself is enough to create the rule. However, for any of the include rules, this
    /// requires resolving the rule from the pattern. It done like this to allow cyclic refernces, such as including
    /// the current grammar with `IncludeGrammarPattern`.
    ///
    /// - parameter grammar: The grammar that is resolving the pattern into a rule.
    ///
    /// - Important: It is important to note that any patterns with sub patterns should **NOT** resolve
    /// them in this method. They will be resolved as needed, doing so could lead to a resolution cycle.
    func resolve(parser: Parser, grammar: Grammar) -> [Rule]
}
