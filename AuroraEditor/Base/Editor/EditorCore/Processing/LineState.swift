//
//  LineState.swift
//  Aurora Editor
//
//  Created by Matthew Davidson on 4/12/19.
//

import Foundation

public struct LineState: Equatable {
    var scopes: [Scope]

    var currentScope: Scope? {
        return scopes.last
    }

    var scopeNames: [ScopeName] {
        return scopes.map({ $0.name })
    }

    public static func == (lhs: LineState, rhs: LineState) -> Bool {
        return lhs.scopes == rhs.scopes
    }
}
