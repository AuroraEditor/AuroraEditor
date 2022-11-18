//
//  Capture.swift
//  
//
//  Created by Matthew Davidson on 7/12/19.
//

import Foundation

///
/// The representation of a capture definition.
///
/// Captures can have apply a name (scope) and/or patterns to the captured text.
///
/// The capture group that this `Capture` is applied to is determined by its position in its rules' captures array.
///
public class Capture: Pattern {

    /// Optional scope to apply to the capture.
    let scopeName: ScopeName

    /// Patterns to apply to the capture.
    var patterns: [Pattern]

    /// Boolean value whether the capture should be applied.
    let isActive: Bool

    /// The lazy resolved rules from the patterns.
    private var rules: [Rule]?

    /// Creates a capture.
    ///
    /// - parameter name: Scope to apply to the capture.
    /// - parameter patterns: Patterns to apply to the capture.
    ///
    public init(name: String? = nil, isActive: Bool = true, patterns: [Pattern] = []) {
        self.scopeName = ScopeName(rawValue: name ?? "")
        self.isActive = isActive
        self.patterns = patterns
    }

    public func resolve(parser: Parser, grammar: Grammar) -> [Rule] {
        if let rules = rules {
            return rules
        }
        var rules = [Rule]()
        for pattern in patterns {
            rules += pattern.resolve(parser: parser, grammar: grammar)
        }
        self.rules = rules
        return rules
    }
}

extension Capture {
    /// None
    public static let none = Capture(isActive: false)
}
