//
//  CodeStorageTokenAttributes.swift
//  AuroraEditor
//
//  Created by Nanashi Li on 2022/09/24.
//  Copyright © 2022 Aurora Company. All rights reserved.
//

import AppKit

extension CodeStorage {

    /// Determine the token attribute value at the given character index. This will be `.tokenBody` if the indexed
    /// character is a body character (i.e., second or later) of a token lexeme.
    func tokenAttribute(at location: Int) -> TokenAttribute<LanguageConfiguration.Token>? {

        // Use the concrete text storage here as `CodeStorage.attributes(_:at:effectiveRange:)` does attribute synthesis
        // that we don't want here.
        return textStorage.attribute(.token, at: location, effectiveRange: nil)
        as? TokenAttribute<LanguageConfiguration.Token>
    }

    /// Determine the type and range of the token to which the character at the given index belongs, if it is part of a
    /// token at all.
    func token(at location: Int) -> (type: LanguageConfiguration.Token, range: NSRange)? {

        func determineTokenLength(type: LanguageConfiguration.Token, start: Int)
        -> (type: LanguageConfiguration.Token, range: NSRange)? {
            var idx = location + 1
            while idx < length, tokenAttribute(at: idx)?.isHead == false { idx += 1 }
            return (type: type, range: NSRange(location: start, length: idx - start))
        }

        var idx = location
        while idx >= 0 && idx < length {

            if let attribute = tokenAttribute(at: idx) {

                if !attribute.isHead { idx -= 1 }   // still looking for the first character of the lexeme
                else {                              // we found the first character of a token

                    return determineTokenLength(type: attribute.token, start: idx)

                }
            } else { return nil }   // no token (head) attribute => character is not part of a token lexeme
        }
        return nil      // this shouldn't happen...
    }

    /// Executes the specified closure for each token in the given range.
    ///
    /// - Parameters:
    ///   - enumerationRange: The range overwhich tokens are enumerated.
    ///   - reverseEnumeration: Pass `true` if the enumeration should proceed in reverse.
    ///   - block: The closure to apply to the token types and ranges found.
    ///
    /// See `NSAttributedString.enumerateAttribute(_:in:options:using:)` for further details of the parameters.
    func enumerateTokens(in enumerationRange: NSRange,
                         reverse reverseEnumeration: Bool = false,
                         using block: (LanguageConfiguration.Token, NSRange, UnsafeMutablePointer<ObjCBool>) -> Void) {
        let opts: NSAttributedString.EnumerationOptions = reverseEnumeration
            ? [.longestEffectiveRangeNotRequired, .reverse]
            : [.longestEffectiveRangeNotRequired]

        enumerateAttribute(.token, in: enumerationRange, options: opts) { (value, range, stop) in
            // we are only interested in non-token body matches
            guard let tokenType = value as? TokenAttribute<LanguageConfiguration.Token>,
                  tokenType.isHead else { return }

        theSwitch: switch range.length {
        case 0:
            break
        case 1:   // we report one token (that possibly extents across mutliple characters
            guard let theToken = token(at: range.location) else { break theSwitch }
            block(theToken.type, theToken.range, stop)
        default:  // we report as many one-character tokens as the length of the `range` specifies
            guard let theRange: Range<Int> = Range(range) else { break theSwitch }

        forLoop: for idx in reverseEnumeration ? theRange.reversed() : Array(theRange) {

            block(tokenType.token, NSRange(location: idx, length: 1), stop)
            if stop.pointee.boolValue { break forLoop }

        }
        }
        }
    }

    /// If there is a bracket at the given location, return its matching bracket's location if it exists and is within
    /// the given range.
    ///
    /// - Parameters:
    ///   - location: Location of the original bracket (maybe opening or closing).
    ///   - range: Range of locations to consider for the matching bracket.
    /// - Returns: Character range of the lexeme of the matching bracket if it exists in the given `range`.
    func matchingBracket(forLocationAt location: Int, in range: NSRange) -> NSRange? {
        guard let bracketToken = token(at: location),
              bracketToken.type.isOpenBracket || bracketToken.type.isCloseBracket
        else { return nil }

        let matchingBracketTokenType = bracketToken.type.matchingBracket
        let searchRange: NSRange
        if bracketToken.type.isOpenBracket {
            // searching to the right
            searchRange = NSRange(location: location + 1, length: max(NSMaxRange(range) - location - 1, 0))

        } else {
            // searching to the left
            searchRange = NSRange(location: range.location, length: max(location - range.location, 0))
        }

        var level = 1
        var matchingRange: NSRange?
        enumerateTokens(in: searchRange, reverse: bracketToken.type.isCloseBracket) { (tokenType, range, stop) in

            if tokenType == bracketToken.type { level += 1 }  // nesting just got deeper
            else if tokenType == matchingBracketTokenType {   // matching bracket found

                if level > 1 { level -= 1 }     // but we are not yet at the topmost nesting level
                else {                          // this is the one actually matching the original bracket
                    matchingRange = range
                    stop.pointee = true

                }
            }
        }
        return matchingRange
    }
}
