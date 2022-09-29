//
//  Parser.swift
//  
//
//  Created by Matthew Davidson on 30/12/19.
//

import Foundation

public class Parser { // swiftlint:disable:this type_body_length

    // Must be anchored to the start of the range and enforce word and line boundaries
    static let matchingOptions = NSRegularExpression
        .MatchingOptions(arrayLiteral: .anchored, .withTransparentBounds, .withoutAnchoringBounds)

    private let grammars: [Grammar]

    public init(grammars: [Grammar]) {
        self.grammars = grammars
        self.grammars.forEach { $0.parser = self }
    }

    public func grammar(withScope scope: String) -> Grammar? {
        return grammars.first(where: { $0.scopeName == scope })
    }

    // swiftlint:disable:next function_body_length function_parameter_count
    fileprivate func applyCapture(grammar: Grammar,
                                  pattern: NSRegularExpression,
                                  capturesToApply: [Capture],
                                  line: String,
                                  loc: Int,
                                  endLoc: Int,
                                  theme: HighlightTheme,
                                  state: LineState,
                                  matchTokens: inout [Token],
                                  tokens: inout [Token]) {
        // Apply capture groups
        for (index, captureRange) in captures(pattern: pattern, str: line,
                                              in: NSRange(location: loc, length: endLoc-loc)).enumerated() {
            guard index < capturesToApply.count else {
                // No capture defined for this (or further) capture(/s).
                break
            }
            // Get the capture definition from the rule
            let capture = capturesToApply[index]

            guard capture.isActive else {
                continue
            }

            // Create a scope for the capture.
            let captureScope = Scope(
                name: capture.scopeName,
                rules: capture.resolve(parser: self, grammar: grammar),
                theme: theme
            )
            // Create the capture state (the current state, with the capture state)
            let captureState = LineState(scopes: state.scopes + [captureScope])

            // Use tokenize on the capture as if it was an entire line.
            let result = tokenize(line: line,
                                  state: captureState,
                                  withTheme: theme,
                                  inRange: captureRange)

            // Adjust and add the match tokens to our match tokens array
            matchTokens += result.matchTokens

            // Create a new array for the new version of the list of tokens.
            var newTokens = [Token]()

            // Merge the original token list with the token list from the tokenized capture line.
            // Strategy:
            // While both lists are not empty, take the first from each list and compare.
            // - If the token from the original list is before the capture list we will either
            //   just add it to the new tokens list if it completely before the other token or
            //   we will split it and add the front bit to the new list.
            // - Otherwise, see if the two tokens have the same range. If so, we merge them add
            //   them to the list. Otherwise we will split the larger one.
            // - Note: the capture line tokens will never occur before the original token because
            //   captures are applied in order.
            while var oToken = tokens.first, var cToken = result.tokenizedLine.tokens.first {
                // Check if the original token is before the new capture token.
                if oToken.range.location < cToken.range.location {
                    var new = oToken
                    // See if they are disjoint
                    if oToken.range.upperBound <= cToken.range.location {
                        tokens.removeFirst()
                    } else {
                        new.range.length = cToken.range.location - oToken.range.location
                        tokens[0].range = NSRange(location: cToken.range.location,
                                                  length: oToken.range.upperBound - cToken.range.location)
                    }

                    newTokens.append(new)
                    continue
                }

                // Now we can guarantee that tokens are both at the same location.
                guard oToken.range.location == cToken.range.location else {
                    fatalError("Tokens are not contiguous")
                }

                // Now three case to merge the tokens:
                // 1. Both are over the same range
                // 2. Need to split cToken
                // 3. Need to split oToken
                if oToken.range.upperBound == cToken.range.upperBound {
                    tokens.removeFirst()
                    result.tokenizedLine.tokens.removeFirst()
                } else if oToken.range.upperBound < cToken.range.upperBound {
                    result.tokenizedLine.tokens[0].range = NSRange(location: oToken.range.upperBound,
                                                                   length: cToken.range.upperBound -
                                                                       oToken.range.upperBound)
                    cToken.range.length = oToken.range.length
                    tokens.removeFirst()
                } else {
                    tokens[0].range = NSRange(location: cToken.range.upperBound,
                                              length: oToken.range.upperBound - cToken.range.upperBound)
                    oToken.range.length = cToken.range.length
                    result.tokenizedLine.tokens.removeFirst()
                }
                // Merge the capture token onto the original token.
                newTokens.append(oToken.mergedWith(cToken))
            }
            // tokens and/or capture line tokens will be empty so it safe to just append them both.
            newTokens += tokens + result.tokenizedLine.tokens

            // Update the tokens.
            tokens = newTokens
        }
    }

    public func tokenize( // swiftlint:disable:this cyclomatic_complexity function_body_length
        line: String,
        state: LineState,
        withTheme theme: HighlightTheme = .default,
        inRange range: NSRange? = nil) -> TokenizeResult {
        debug("Tokenizing line: \(line)")
        var state = state

        var loc = range?.location ?? 0
        let endLoc = range?.upperBound ?? line.utf16.count
        let tokenizedLine = TokenizedLine(tokens: [
            Token(
                range: NSRange(location: loc, length: 0),
                scopes: state.scopes
            )
        ])

        var matchTokens = [Token]()
        while loc < endLoc {
            // Before we apply the rules in the current scope, see if we are
            // in a BeginEndRule and reached the end of its scope.
            if let endPattern = state.currentScope?.end {
                if let newPos = matches(pattern: endPattern, str: line,
                                        in: NSRange(location: loc, length: endLoc-loc)) {
                    // Pop off state.
                    let last = state.scopes.removeLast()
                    // If the state is a content state, pop off the next as well.
                    if last.isContentScope {
                        // Create a new token for the end match of the BeginEndRule
                        tokenizedLine.addToken(Token(
                            range: NSRange(location: loc, length: newPos - loc),
                            scopes: state.scopes
                        ))
                        state.scopes.removeLast()
                    } else {
                        // Extend the length of current token to include the end match of the BeginEndRule
                        tokenizedLine.increaseLastTokenLength(by: newPos - loc)
                    }
                    // Update the location and start a new token.
                    loc = newPos
                    tokenizedLine.addToken(Token(
                        range: NSRange(location: loc, length: 0),
                        scopes: state.scopes
                    ))
                    continue
                }
            }

            // Get the current scope, to get the rules.
            // There may not always be rules, but there should always be a scope
            guard let currentScope = state.currentScope else {
                // Shouldn't happen
                fatalError("Failed to tokenize line: '\(line)' because the state's current scope is nil.")
            }

            // Apply the rules in order, looking for a match
            var matched = false
            for rule in currentScope.rules {
                // Apply the match rule
                if let rule = rule as? MatchRule {
                    if let newPos = matches(pattern: rule.match, str: line,
                                            in: NSRange(location: loc, length: endLoc-loc)) {
                        // Set matched flag
                        matched = true
                        // Create a new scope
                        let scope = Scope(
                            name: rule.scopeName,
                            rules: [],
                            theme: theme
                        )

                        // Create ordered list of tokens
                        // Start with just one token for the entire range of the match.
                        // This will be manipulated if there are capture groups.
                        let matchToken = Token(
                            range: NSRange(location: loc, length: newPos - loc),
                            scopes: state.scopes + [scope]
                        )
                        var tokens = [matchToken]

                        // Add to matchTokens
                        matchTokens.append(matchToken)

                        applyCapture(grammar: rule.grammar!,
                                     pattern: rule.match,
                                     capturesToApply: rule.captures,
                                     line: line,
                                     loc: loc,
                                     endLoc: endLoc,
                                     theme: theme,
                                     state: state,
                                     matchTokens: &matchTokens,
                                     tokens: &tokens)

                        tokenizedLine.addTokens(tokens)

                        // Prepare for next char.
                        loc = newPos
                        tokenizedLine.addToken(Token(
                            range: NSRange(location: loc, length: 0),
                            scopes: state.scopes
                        ))
                        break
                    }
                }
                // Apply the begin end rule
                else if let rule = rule as? BeginEndRule {
                    if let newPos = matches(pattern: rule.begin, str: line,
                                            in: NSRange(location: loc, length: endLoc-loc)),
                       newPos > loc {
                        // Set matched flag
                        matched = true
                        // Create a new scope for the BeginEndRule and add it to the state.
                        let scope = Scope(
                            name: rule.scopeName,
                            rules: rule.resolveRules(parser: self, grammar: rule.grammar!),
                            end: rule.end,
                            theme: theme
                        )
                        state.scopes.append(scope)

                        // Add a new token for the begin match of the BeginEndRule
                        let matchToken = Token(
                            range: NSRange(location: loc, length: newPos - loc),
                            scopes: state.scopes
                        )
                        var tokens = [matchToken]

                        applyCapture(grammar: rule.grammar!,
                                     pattern: rule.begin,
                                     capturesToApply: rule.beginCaptures,
                                     line: line,
                                     loc: loc,
                                     endLoc: endLoc,
                                     theme: theme,
                                     state: state,
                                     matchTokens: &matchTokens,
                                     tokens: &tokens)

                        // If the BeginEndRule has a content name:
                        if let contentName = rule.contentScopeName {
                            // Add an additional scope, with the same rules and end pattern.
                            // Set the isContentScope flag so we know what to do when we find the end match
                            state.scopes.append(Scope(
                                name: contentName,
                                rules: rule.resolveRules(parser: self, grammar: rule.grammar!),
                                end: rule.end,
                                theme: theme,
                                isContentScope: true
                            ))
                            // Start a new token for the content between the begin and end matches.
                            tokens.append(Token(
                                range: NSRange(location: newPos, length: 0),
                                scopes: state.scopes
                            ))
                        }

                        tokenizedLine.addTokens(tokens)
                        loc = newPos
                        break
                    }
                }
            }
            // No matches at the current position.
            // Increase the length of the current token and move to the next character.
            if !matched {
                tokenizedLine.increaseLastTokenLength()
                loc += 1
            }
        }
        tokenizedLine.cleanLast()

        for token in tokenizedLine.tokens {
            let startIndex = line.utf16.index(line.utf16.startIndex, offsetBy: token.range.location)
            let endIndex = line.utf16.index(line.utf16.startIndex, offsetBy: token.range.upperBound)
            debug(
"""
- Token from \(token.range.location) to \(token.range.upperBound) \
'\(line[startIndex..<endIndex])' with scopes: \
[\(token.scopeNames.map { $0.rawValue }.joined(separator: ", "))]
"""
)
        }
        return TokenizeResult(state: state, tokenizedLine: tokenizedLine, matchTokens: matchTokens)
    }

    func matches(pattern: NSRegularExpression, str: String, in range: NSRange) -> Int? {
        let matchRange = pattern.rangeOfFirstMatch(in: str, options: Self.matchingOptions, range: range)
        if matchRange.location != NSNotFound {
            return matchRange.upperBound
        } else {
            return nil
        }
    }

    func captures(pattern: NSRegularExpression, str: String, in range: NSRange) -> [NSRange] {
        if let match = pattern.firstMatch(in: str, options: Self.matchingOptions, range: range) {
            return (0..<match.numberOfRanges).compactMap { index -> NSRange? in
                let captureRange = match.range(at: index)
                guard captureRange.location != NSNotFound else {
                    return nil
                }
                return  match.range(at: index)
            }
        } else {
            return []
        }
    }

    public var shouldDebug = true

    func debug(_ str: String) {
        if shouldDebug {
            print(str) // swiftlint:disable:this disallow_print
        }
    }
}
