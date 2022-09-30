//
//  TokenizedLine.swift
//  
//
//  Created by Matthew Davidson on 4/12/19.
//

import Foundation

public class TokenizedLine {

    var tokens: [Token]

    init(tokens: [Token] = []) {
        self.tokens = tokens
    }

    public var length: Int {
        guard let last = tokens.last else {
            return 0
        }
        return last.range.upperBound
    }

    func addToken(_ token: Token) {
        cleanLast()
        tokens.append(token)
    }

    func addTokens(_ tokens: [Token]) {
        cleanLast()
        self.tokens += tokens
    }

    func cleanLast() {
        if tokens.last?.range.length == 0 {
            tokens.removeLast()
        }
    }

    func increaseLastTokenLength(by len: Int = 1) {
        // TODO: Check if this is needed, it 'can' crash the app without any reason
        // it seems to work without it.
//        tokens[tokens.count - 1].range.length += len
    }

    private static func applyThemeAttributes(_ attributes: [ThemeAttribute],
                                             toStr attributedString: NSMutableAttributedString,
                                             withStyle style: MutableParagraphStyle,
                                             andRange range: NSRange) {
        for attr in attributes {
            if let lineAttr = attr as? LineThemeAttribute {
                lineAttr.apply(to: style)
            } else if let tokenAttr = attr as? TokenThemeAttribute {
                tokenAttr.apply(to: attributedString, withRange: range)
            } else {
                // swiftlint:disable:this disallow_print
                print("""
                      Warning: ThemeAttribute with key \(attr.key) does not conform \
                      to either LineThemeAttribute or TokenThemeAttribtue so it will not be applied.
                      """)
            }
        }
    }

    ///
    /// Applies the theming of the tokenized line to a given mutable attributed string at the given location.
    ///
    /// - Parameter attributedString: The mutable attributed string to apply the attributes to.
    /// - Parameter loc: The (NSString indexed) location to apply the theming from.
    /// - Parameter inSelectedScope: Whether the current selection is on any part of the line that is being themed.
    /// - Parameter applyBaseAttributes: Whether the base should be applied as well selection scope attributes.
    ///
    public func applyTheme(
        _ attributedString: NSMutableAttributedString,
        at loc: Int,
        inSelectionScope: Bool = false,
        applyBaseAttributes: Bool = true
    ) {

        // If we are applying the base attributes we will reset the attributes of the attributed string.
        // Otherwise, we will leave them and create a mutable copy of the paragraph style.
        var style = MutableParagraphStyle()
        if applyBaseAttributes {
            attributedString.setAttributes(nil, range: NSRange(location: loc, length: length))
        } else if let currStyle = (attributedString.attribute(.paragraphStyle, at: loc,
                                                              effectiveRange: nil)
                                   as? ParagraphStyle)?.mutableCopy() as? MutableParagraphStyle {
            style = currStyle
        }

        for token in tokens {
            for scope in token.scopes {
                if applyBaseAttributes {
                    TokenizedLine.applyThemeAttributes(
                        scope.attributes,
                        toStr: attributedString,
                        withStyle: style,
                        andRange: NSRange(location: loc + token.range.location, length: token.range.length))
                }
                if inSelectionScope {
                    TokenizedLine.applyThemeAttributes(
                        scope.inSelectionAttributes,
                        toStr: attributedString,
                        withStyle: style,
                        andRange: NSRange(location: loc + token.range.location, length: token.range.length))
                } else {
                    TokenizedLine.applyThemeAttributes(
                        scope.outSelectionAttributes,
                        toStr: attributedString,
                        withStyle: style,
                        andRange: NSRange(location: loc + token.range.location, length: token.range.length))
                }
            }
        }

        attributedString.addAttribute(.paragraphStyle, value: style, range: NSRange(location: loc, length: length))
    }
}
