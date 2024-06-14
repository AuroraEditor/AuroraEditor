//
//  LineState.swift
//  Aurora Editor
//
//  Created by Matthew Davidson on 4/12/19.
//  Copyright © 2023 Aurora Company. All rights reserved.
//

import Foundation

// TODO: @0xWDG Look if this can be removed.
/// The state of a line.
public struct LineState: Equatable {
    /// The scopes of the line.
    var scopes: [Scope]

    /// The current scope.
    var currentScope: Scope? {
        return scopes.last
    }

    /// Scope names
    var scopeNames: [ScopeName] {
        return scopes.map({ $0.name })
    }

    /// Equate
    /// 
    /// - Parameter lhs: left hand side
    /// - Parameter rhs: right hand side
    /// 
    /// - Returns: true if equal
    public static func == (lhs: LineState, rhs: LineState) -> Bool {
        return lhs.scopes == rhs.scopes
    }
}
