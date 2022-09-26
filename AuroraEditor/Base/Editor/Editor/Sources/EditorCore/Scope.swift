//
//  Scope.swift
//  
//
//  Created by Matthew Davidson on 4/12/19.
//

import Foundation

class Scope {
    var name: ScopeName
    var rules: [Rule]
    var end: NSRegularExpression?
    var attributes: [ThemeAttribute]
    var inSelectionAttributes: [ThemeAttribute]
    var outSelectionAttributes: [ThemeAttribute]
    var isContentScope = false

    init(
        name: ScopeName,
        rules: [Rule],
        end: NSRegularExpression? = nil,
        attributes: [ThemeAttribute],
        inSelectionAttributes: [ThemeAttribute],
        outSelectionAttributes: [ThemeAttribute],
        isContentScope: Bool = false
    ) {
        self.name = name
        self.rules = rules
        self.end = end
        self.attributes = attributes
        self.inSelectionAttributes = inSelectionAttributes
        self.outSelectionAttributes = outSelectionAttributes
        self.isContentScope = isContentScope
    }

    init(
        name: ScopeName,
        rules: [Rule],
        end: NSRegularExpression? = nil,
        theme: EditorTheme,
        isContentScope: Bool = false
    ) {
        self.name = name
        self.rules = rules
        self.end = end
        (self.attributes, self.inSelectionAttributes, self.outSelectionAttributes) =
            theme.allAttributes(forScopeName: name)
        self.isContentScope = isContentScope
    }
}

extension Scope: Equatable {

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
