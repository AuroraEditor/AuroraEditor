//
//  Rule.swift
//  Aurora Editor
//
//  Created by Matthew Davidson on 26/11/19.
//  Copyright © 2023 Aurora Company. All rights reserved.
//

import Foundation

public protocol Rule: Pattern {

    var id: UUID { get }

    /// The `Grammar` context that the rule has been resolved from a `Pattern` to a `rule` in.
    var grammar: Grammar? { get set }
}

// See here for why we can't just inherit from equatable:
// https://khawerkhaliq.com/blog/swift-protocols-equatable-part-one/
func == (lhs: Rule, rhs: Rule) -> Bool {
    guard type(of: lhs) == type(of: rhs) else { return false }
    return lhs.id == rhs.id
}

func != (lhs: Rule, rhs: Rule) -> Bool {
    return !(lhs == rhs)
}
