//
//  BeginEndRule.swift
//  Aurora Editor
//
//  Created by Matthew Davidson on 26/11/19.
//  Copyright © 2023 Aurora Company. All rights reserved.
//

import Foundation
import OSLog

// TODO: @0xWDG Look if this can be removed.
/// The representation of the Begin/End rule.
public class BeginEndRule: Rule, Pattern {
    /// The id of the rule.
    public let id: UUID

    /// The grammar this rule belongs to.
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

    /// The captures for the begin pattern.
    var beginCaptures: [Capture]

    /// The captures for the end pattern.
    var endCaptures: [Capture]

    /// Whether the end pattern has back references.
    var endHasBackReferences: Bool

    /// The resolved rules from the patterns.
    private var rules: [Rule]?

    /// Logger
    let logger = Logger(subsystem: "com.auroraeditor", category: "BeginEndRule")

    /// Creates a begin/end rule.
    /// 
    /// - parameter name: The name of the rule.
    /// - parameter begin: The begin pattern.
    /// - parameter end: The end pattern.
    /// - parameter contentName: The name of the content scope.
    /// - parameter patterns: The patterns to apply within the begin/end patterns.
    /// - parameter beginCaptures: The captures for the begin pattern.
    /// - parameter endCaptures: The captures for the end pattern.
    /// - parameter endHasBackReferences: Whether the end pattern has back references.
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
                pattern: begin.first == "{" ? begin.replacingOccurrences(of: "{", with: "\\{") : begin,
                options: .init(
                    arrayLiteral: .anchorsMatchLines,
                    .dotMatchesLineSeparators
                )
            )
        } catch {
            var message = "Could not create begin regex for BeginEndRule, "
            message += "name(\"\(name)\"), begin(\"\(begin)\"), end(\"\(end)\"), "
            message += "error: \"\(error.localizedDescription)\""

            self.logger.warning("\(message)")
            self.begin = .init()
        }
        do {
            self.end = try NSRegularExpression(
                pattern: end.first == "}" ? end.replacingOccurrences(of: "}", with: "\\}") : end,
                options: .init(
                    arrayLiteral: .anchorsMatchLines,
                    .dotMatchesLineSeparators
                )
            )
        } catch {
            var message = "Could not create end regex for BeginEndRule, "
            message += "name(\"\(name)\"), begin(\"\(begin)\"), end(\"\(end)\"), "
            message += "error: \"\(error.localizedDescription)\""

            self.logger.warning("\(message)")
            self.end = .init()
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

    /// Resolves the rule into rules.
    /// 
    /// - parameter parser: The parser to use for resolving patterns.
    /// - parameter grammar: The grammar to use for resolving patterns.
    /// 
    /// - returns: The resolved rules.
    public func resolve(parser: Parser, grammar: Grammar) -> [Rule] {
        self.grammar = grammar
        return [self]
    }

    /// Resolves the rule into rules.
    /// 
    /// - parameter parser: The parser to use for resolving patterns.
    /// - parameter grammar: The grammar to use for resolving patterns.
    /// 
    /// - returns: The resolved rules.
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
