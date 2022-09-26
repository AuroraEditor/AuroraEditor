//
//  ThemeSetting.swift
//  
//
//  Created by Matthew Davidson on 4/12/19.
//

import Foundation

public struct ThemeSetting {

    var scope: String
    var parentScopes: [String]

    var attributes: [ThemeAttribute]
    var inSelectionAttributes: [ThemeAttribute]
    var outSelectionAttributes: [ThemeAttribute]

    var scopeComponents: [Substring] {
        return scope.split(separator: ".")
    }

    ///
    /// Constructor
    ///
    /// - Parameter scope: Dot separated scope to apply the theme setting to.
    /// - Parameter parentScopes: **NOT IMPLEMENTED**
    /// - Parameter attributes: Base attributes to apply to text that matches the scope.
    /// - Parameter inSelectionAttributes: Attributes to apply to text that matches the scope
    ///     on a line which has some part of the selection.
    /// - Parameter outSelectionAttributes: Attributes to apply to text that matches the scope
    ///     on a line which does not have some part of the selection.
    ///
    public init(
        scope: String,
        parentScopes: [String] = [],
        attributes: [ThemeAttribute] = [],
        inSelectionAttributes: [ThemeAttribute] = [],
        outSelectionAttributes: [ThemeAttribute] = []
    ) {
        self.scope = scope
        self.parentScopes = parentScopes
        self.attributes = attributes
        self.inSelectionAttributes = inSelectionAttributes
        self.outSelectionAttributes = outSelectionAttributes
    }
}
