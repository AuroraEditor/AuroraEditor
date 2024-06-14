//
//  Rule.swift
//  Aurora Editor
//
//  Created by Matthew Davidson on 26/11/19.
//  Copyright © 2023 Aurora Company. All rights reserved.
//

import Foundation

// TODO: @0xWDG Look if this can be removed.
/// A rule that matches a pattern.
public protocol Rule: Pattern {

    /// The id of the rule.
    var id: UUID { get }

    /// The `Grammar` context that the rule has been resolved from a `Pattern` to a `rule` in.
    var grammar: Grammar? { get set }
}

// See here for why we can't just inherit from equatable:
// https://khawerkhaliq.com/blog/swift-protocols-equatable-part-one/
/// Equatable implementation for `Rule`.
/// 
/// - Parameter lhs: The left hand side of the equality.
/// - Parameter rhs: The right hand side of the equality.
/// 
/// - Returns: `true` if the rules are equal, `false` otherwise.
func == (lhs: Rule, rhs: Rule) -> Bool {
    guard type(of: lhs) == type(of: rhs) else { return false }
    return lhs.id == rhs.id
}

/// Inequality implementation for `Rule`.
/// 
/// - Parameter lhs: The left hand side of the inequality.
/// - Parameter rhs: The right hand side of the inequality.
/// 
/// - Returns: `true` if the rules are not equal, `false` otherwise.
func != (lhs: Rule, rhs: Rule) -> Bool {
    return !(lhs == rhs)
}
