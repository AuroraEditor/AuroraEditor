//
//  TokenizedLine.swift
//  
//
//  Created by Matthew Davidson on 4/12/19.
//

import Foundation
import AppKit

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
        guard !tokens.isEmpty else { return }
        tokens[tokens.count - 1].range.length += len
    }

    private static func applyThemeAttributes(_ attributes: [ThemeAttribute],
                                             toStr attributedString: NSMutableAttributedString,
                                             withStyle style: NSMutableParagraphStyle,
                                             andRange range: NSRange) {
        for attr in attributes {
            if let lineAttr = attr as? LineThemeAttribute {
                lineAttr.apply(to: style)
            } else if let tokenAttr = attr as? TokenThemeAttribute {
                tokenAttr.apply(to: attributedString, withRange: range)
            } else {
                Log.info("""
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
        var style = NSMutableParagraphStyle()
        if applyBaseAttributes,
           let range = attributedString.rangeWithinString(from: NSRange(location: loc, length: length)) {
            attributedString.setAttributes(nil, range: range)
        } else if let currStyle = (attributedString.attribute(.paragraphStyle, at: loc,
                                                              effectiveRange: nil)
                                   as? NSParagraphStyle)?.mutableCopy() as? NSMutableParagraphStyle {
            style = currStyle
        }

        for token in tokens {
            guard let range = attributedString.rangeWithinString(from: NSRange(location: loc + token.range.location,
                                                                               length: token.range.length))
            else { return }

            // set the token NSAttributedString attribute, used for debugging
            attributedString.addAttributes([.token: token], range: range)

            for scope in token.scopes {
                if applyBaseAttributes {
                    TokenizedLine.applyThemeAttributes(
                        scope.attributes,
                        toStr: attributedString,
                        withStyle: style,
                        andRange: range)
                }
                if inSelectionScope {
                    TokenizedLine.applyThemeAttributes(
                        scope.inSelectionAttributes,
                        toStr: attributedString,
                        withStyle: style,
                        andRange: range)
                } else {
                    TokenizedLine.applyThemeAttributes(
                        scope.outSelectionAttributes,
                        toStr: attributedString,
                        withStyle: style,
                        andRange: range)
                }
            }
        }

        if let range = attributedString.rangeWithinString(from: NSRange(location: loc, length: length)) {
            attributedString.addAttribute(.paragraphStyle, value: style,
                                          range: range)
        }
    }
}

extension NSAttributedString {
    func rangeWithinString(from range: NSRange) -> NSRange? {
        NSRange(location: 0, length: self.length).intersection(range)
    }
}
