//
//  BeginEndRule.swift
//
//
//  Created by Matthew Davidson on 26/11/19.
//

import Foundation

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
    var begin: NSRegularExpression

    /// The end regex for the rule.
    ///
    /// Ensure special characters are escaped correctly.
    var end: NSRegularExpression

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
            self.begin = try NSRegularExpression(
                pattern: begin == "{" ? begin.replacingOccurrences(of: "{", with: "\\{") : begin,
                options: .init(
                    arrayLiteral: .anchorsMatchLines,
                    .dotMatchesLineSeparators
                )
            )
            self.end = try NSRegularExpression(
                pattern: end == "}" ? end.replacingOccurrences(of: "}", with: "\\}") : end,
                options: .init(
                    arrayLiteral: .anchorsMatchLines,
                    .dotMatchesLineSeparators
                )
            )
        } catch {
            var message = "Could not create regex for BeginEndRule, "
            message += "name(\"\(name)\"), begin(\"\(begin)\"), end(\"\(end)\"), "
            message += "error: \"\(error.localizedDescription)\""

            Log.error(message)
            fatalError(message.replacingOccurrences(of: "\n", with: ""))
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
