//
//  Scope.swift
//  Aurora Editor
//
//  Created by Matthew Davidson on 4/12/19.
//  Copyright © 2023 Aurora Company. All rights reserved.
//

import Foundation

// TODO: @0xWDG Look if this can be removed.
/// Scope for a rule.
class Scope {
    /// The name of the scope.
    var name: ScopeName

    /// The rules for this scope.
    var rules: [Rule]

    /// The end pattern for this scope.
    var end: NSRegularExpression?

    /// The attributes to apply to the scope.
    var attributes: [ThemeAttribute]

    /// The attributes to apply to the scope when it is in a selection.
    var inSelectionAttributes: [ThemeAttribute]

    /// The attributes to apply to the scope when it is out of a selection.
    var outSelectionAttributes: [ThemeAttribute]

    /// Whether this scope is a content scope.
    var isContentScope = false

    /// The theme for this scope.
    var theme: HighlightTheme?

    /// The captures for the end pattern.
    var endCaptures: [Capture]

    /// The grammar this scope belongs to.
    var grammar: Grammar?

    /// Initialize Scope
    /// 
    /// - Parameter name: Scope name
    /// - Parameter rules: Rules
    /// - Parameter end: End
    /// - Parameter attributes: Attributes
    /// - Parameter inSelectionAttributes: In selection attributes
    /// - Parameter outSelectionAttributes: Out selection attributes
    /// - Parameter isContentScope: Is content scope
    /// - Parameter endCaptures: End captures
    /// - Parameter grammar: Grammar
    init(
        name: ScopeName,
        rules: [Rule],
        end: NSRegularExpression? = nil,
        attributes: [ThemeAttribute],
        inSelectionAttributes: [ThemeAttribute],
        outSelectionAttributes: [ThemeAttribute],
        isContentScope: Bool = false,
        endCaptures: [Capture] = [],
        grammar: Grammar? = nil
    ) {
        self.name = name
        self.rules = rules
        self.end = end
        self.attributes = attributes
        self.inSelectionAttributes = inSelectionAttributes
        self.outSelectionAttributes = outSelectionAttributes
        self.isContentScope = isContentScope
        self.endCaptures = endCaptures
        self.grammar = grammar
    }

    /// Initialize Scope
    /// 
    /// - Parameter name: Scope name
    /// - Parameter rules: Rules
    /// - Parameter end: End
    /// - Parameter theme: Theme
    /// - Parameter isContentScope: Is content scope
    /// - Parameter endCaptures: End captures
    /// - Parameter grammar: Grammar
    init(
        name: ScopeName,
        rules: [Rule],
        end: NSRegularExpression? = nil,
        theme: HighlightTheme,
        isContentScope: Bool = false,
        endCaptures: [Capture] = [],
        grammar: Grammar? = nil
    ) {
        self.name = name
        self.rules = rules
        self.end = end
        (self.attributes, self.inSelectionAttributes, self.outSelectionAttributes) =
            theme.allAttributes(forScopeName: name)
        self.theme = theme
        self.isContentScope = isContentScope
        self.endCaptures = endCaptures
        self.grammar = grammar
    }
}

extension Scope: Equatable {
    /// Equate
    /// 
    /// - Parameter lhs: left hand side
    /// - Parameter rhs: right hand side
    /// 
    /// - Returns: true if equal
    static func == (lhs: Scope, rhs: Scope) -> Bool {
        if lhs.name != rhs.name { return false }
        if lhs.end != rhs.end { return false }
        if lhs.rules.count != rhs.rules.count { return false }
        for (first, second) in zip(lhs.rules, rhs.rules) where first != second {
            return false
        }
        return true
    }
}
