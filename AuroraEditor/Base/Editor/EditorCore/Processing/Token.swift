//
//  Token.swift
//  
//
//  Created by Matthew Davidson on 4/12/19.
//

import Foundation

/// Token
public struct Token {
    /// Token range
    public var range: NSRange
    /// Token scopes
    var scopes: [Scope]
    /// Token scope names
    public var scopeNames: [ScopeName] {
        return scopes.map({ $0.name })
    }

    ///
    /// Merges the new token onto the base token and returns a new merged token.
    ///
    /// Both tokens must have the same range.
    ///
    /// The merging strategy is simple. The scopes of the merged token is the base tokens scopes + new tokens scopes
    /// without duplicating common contiguously in order base scopes. For example:
    /// - base scopes: [A, B, C, D, E]
    /// - new scopes: [A, B, C, E, F]
    /// - merged scopes: [A, B, C, D, E, E, F]
    ///
    /// - parameter base: The token to be merged onto.
    /// - parameter new: The token to merge onto the base.
    /// - returns: The merged token.
    ///
    static func mergeTokens(base: Token, new: Token) -> Token {
        guard base.range == new.range else {
            fatalError("Should not be merging tokens with different ranges.")
        }

        // Remove common base scopes
        var scopeIndex = 0
        while scopeIndex < new.scopes.count {
            guard scopeIndex < base.scopeNames.count else {
                break
            }
            if new.scopeNames[scopeIndex] != base.scopeNames[scopeIndex] {
                break
            }
            scopeIndex += 1
        }
        var merged = new
        merged.scopes.removeFirst(scopeIndex)
        merged.scopes = base.scopes + merged.scopes

        return merged
    }

    func mergedWith(_ token: Token) -> Token {
        return Self.mergeTokens(base: self, new: token)
    }

    /// Shift token (alias for: `range.shifted`)
    /// - Parameter amount: amount
    public mutating func shift(by amount: Int) {
        range = range.shifted(by: amount)
    }

    /// Shift token (alias for: `range.shifted`)
    /// - Parameter amount: amount
    public func shifted(by amount: Int) -> Token {
        var new = self
        new.range = range.shifted(by: amount)
        return new
    }
}
