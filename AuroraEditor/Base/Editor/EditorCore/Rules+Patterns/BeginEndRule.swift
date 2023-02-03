//
//  BeginEndRule.swift
//  Aurora Editor
//
//  Created by Matthew Davidson on 26/11/19.
//  Copyright © 2023 Aurora Company. All rights reserved.
//

import Foundation
import SwiftOniguruma

///
/// The representation of the Begin/End rule.
///
public class BeginEndRule: Rule, Pattern {

    public let id: UUID

    public weak var grammar: Grammar?

    /// The name of the rule, i.e. the scope.
    let scopeName: ScopeName

    /// The begin regex for the rule.
    ///
    /// Ensure special characters are escaped correctly.
    var begin: SwiftOniguruma.Regex

    /// The end regex for the rule.
    ///
    /// Ensure special characters are escaped correctly.
    var end: SwiftOniguruma.Regex

    /// The patterns to apply within the begin and end patterns.
    var patterns: [Pattern]

    /// The name/scope assigned to text matched between the begin/end patterns.
    let contentScopeName: ScopeName?

    var beginCaptures: [Capture]

    var endCaptures: [Capture]

    var endHasBackReferences: Bool

    private var rules: [Rule]?

    public init(
        name: String,
        begin: String,
        end: String,
        contentName: String? = nil,
        patterns: [Pattern],
        beginCaptures: [Capture] = [],
        endCaptures: [Capture] = [],
        endHasBackReferences: Bool = false
    ) {
        self.id = UUID()
        self.scopeName = ScopeName(rawValue: name)
        do {
            self.begin = try SwiftOniguruma.Regex(
                pattern: begin.first == "{" ? begin.replacingOccurrences(of: "{", with: "\\{") : begin
            )
        } catch {
            var message = "Could not create begin regex for BeginEndRule, "
            message += "name(\"\(name)\"), begin(\"\(begin)\"), end(\"\(end)\"), "
            message += "error: \"\(error.localizedDescription)\""

            Log.warning(message)
            self.begin = try! SwiftOniguruma.Regex(pattern: "") // swiftlint:disable:this force_try
        }
        do {
            self.end = try SwiftOniguruma.Regex(
                pattern: end.first == "}" ? end.replacingOccurrences(of: "}", with: "\\}") : end
            )
        } catch {
            var message = "Could not create end regex for BeginEndRule, "
            message += "name(\"\(name)\"), begin(\"\(begin)\"), end(\"\(end)\"), "
            message += "error: \"\(error.localizedDescription)\""

            Log.warning(message)
            self.end = try! SwiftOniguruma.Regex(pattern: "") // swiftlint:disable:this force_try
        }
        self.patterns = patterns
        if let contentName = contentName {
            self.contentScopeName = ScopeName(rawValue: contentName)
        } else {
            self.contentScopeName = nil
        }
        self.beginCaptures = beginCaptures
        self.endCaptures = endCaptures
        self.endHasBackReferences = endHasBackReferences
    }

    public func resolve(parser: Parser, grammar: Grammar) -> [Rule] {
        self.grammar = grammar
        return [self]
    }

    func resolveRules(parser: Parser, grammar: Grammar) -> [Rule] {
        if let rules = rules {
            return rules
        }
        var rules = [Rule]()
        for pattern in patterns {
            rules += pattern.resolve(parser: parser, grammar: self.grammar!)
        }
        self.rules = rules
        return rules
    }
}
