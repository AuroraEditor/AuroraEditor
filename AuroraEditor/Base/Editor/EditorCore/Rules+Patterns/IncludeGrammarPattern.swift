//
//  IncludeGrammarPattern.swift
//  Aurora Editor
//
//  Created by Matthew Davidson on 28/11/19.
//  Copyright © 2023 Aurora Company. All rights reserved.
//

import Foundation

public class IncludeGrammarPattern: Pattern {

    let scopeName: String

    ///
    /// Includes a grammar identified by its scope name.
    ///
    /// - Parameter scopeName: The base scope name of the grammar.
    ///
    public init(scopeName: String) {
        self.scopeName = scopeName
    }

    public func resolve(parser: Parser, grammar: Grammar) -> [Rule] {
        if let grammar = parser.grammar(withScope: scopeName) {
            return grammar.rules
        } else {
            fatalError("Warning: There is no grammar in the parser with the scope name: '\(scopeName)'")
        }
    }
}
