//
//  Grammar.swift
//  
//
//  Created by Matthew Davidson on 26/11/19.
//

import Foundation

///
/// The representation of a grammar
///
public class Grammar {

    /// The root scope of this grammar.
    public var scopeName: String

    /// The file types this grammar should be used for.
    public var fileTypes: [String]

    /// The root level patterns for this grammar.
    public var patterns: [Pattern]

    /// The folding start marker
    public var foldingStartMarker: String?

    /// The folding end marker
    public var foldingStopMarker: String?

    /// This grammar's repository of patterns
    public var repository: Repository?

    private var _rules: [Rule]?

    internal weak var parser: Parser?

    var rules: [Rule] {
        if let rules = _rules {
            return rules
        }
        _rules = resolveRules()
        return _rules!
    }

    public init(
        scopeName: String,
        fileTypes: [String] = [],
        patterns: [Pattern] = [],
        foldingStartMarker: String? = nil,
        foldingStopMarker: String? = nil,
        repository: Repository? = nil
    ) {
        self.scopeName = scopeName
        self.fileTypes = fileTypes
        self.patterns = patterns
        self.foldingStartMarker = foldingStartMarker
        self.foldingStopMarker = foldingStopMarker
        self.repository = repository
    }

    public func createFirstLineState(theme: Theme = .default) -> LineState {
        return LineState(scopes: [
            Scope(
                name: ScopeName(rawValue: scopeName),
                rules: rules,
                end: nil,
                theme: theme
            )
        ])
    }

    public func baseAttributes(forTheme theme: Theme) -> [NSAttributedString.Key: Any] {
        let line = TokenizedLine(tokens: [
            Token(
                range: NSRange(location: 0, length: 1),
                scopes: [
                    Scope(
                        name: ScopeName(rawValue: scopeName),
                        rules: [],
                        theme: theme
                    )
                ]
            )
        ])
        let str = NSMutableAttributedString(string: "a")
        line.applyTheme(str, at: 0)
        return str.attributes(at: 0, effectiveRange: nil)
    }

    private func resolveRules() -> [Rule] {
        guard let parser = parser else {
            fatalError("Could not resolve rules for grammar with scope name '\(scopeName)' because it was not owned by a Parser.")
        }

        var rules = [Rule]()

        for pattern in patterns {
            rules += pattern.resolve(parser: parser, grammar: self)
        }

        return rules
    }
}
