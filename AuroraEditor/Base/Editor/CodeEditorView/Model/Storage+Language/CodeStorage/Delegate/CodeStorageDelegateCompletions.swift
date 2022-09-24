//
//  CodeStorageDelegateCompletions.swift
//  AuroraEditor
//
//  Created by Nanashi Li on 2022/09/24.
//  Copyright © 2022 Aurora Company. All rights reserved.
//

import AppKit

extension CodeStorageDelegate {

    /// Handle token completion actions after a single character was inserted.
    ///
    /// - Parameters:
    ///   - textStorage: The text storage where the edit action occured.
    ///   - index: The location within the text storage where the single chracter was inserted.
    ///
    /// Any change to the `textStorage` is deferred, so that this function can also be used in the middle of an
    /// in-progress, but not yet completed edit.
    func tokenCompletion(for codeStorage: CodeStorage, at index: Int) {

        /// If the given token is an opening bracket, return the lexeme of its matching closing bracket.
        func matchingLexemeForOpeningBracket(_ token: LanguageConfiguration.Token) -> String? {
            if token.isOpenBracket, let matching = token.matchingBracket, let lexeme = language.lexeme(of: matching) {
                return lexeme
            } else {
                return nil
            }
        }

        /// Determine whether the ranges of the two tokens are overlapping.
        func overlapping(_ previousToken: (type: LanguageConfiguration.Token, range: NSRange),
                         _ currentToken: (type: LanguageConfiguration.Token, range: NSRange)?) -> Bool {
            if let currentToken = currentToken {
                return NSIntersectionRange(previousToken.range, currentToken.range).length != 0
            } else { return false }
        }

        let string = codeStorage.string,
            char = string.utf16[string.index(string.startIndex, offsetBy: index)],
            previousTypedToken = lastTypedToken,
            currentTypedToken: (type: LanguageConfiguration.Token, range: NSRange)?

        // Determine the token (if any) that the right now inserted character belongs to
        currentTypedToken = codeStorage.token(at: index)

        lastTypedToken = currentTypedToken    // this is the default outcome, unless explicitly overridden below

        // The just entered character is right after the previous token and it doesn't belong to a token
        // overlapping with the previous token
        if let previousToken = previousTypedToken, NSMaxRange(previousToken.range) == index,
           !overlapping(previousToken, currentTypedToken) {

            let completingString: String?

            // If the previous token was an opening bracket, we may have to autocomplete by inserting a matching closing
            // bracket
            if let matchingPreviousLexeme = matchingLexemeForOpeningBracket(previousToken.type) {

                if let currentToken = currentTypedToken {

                    if currentToken.type == previousToken.type.matchingBracket {

                        // The current token is a matching closing bracket for the opening bracket\
                        // of the last token => nothing to do
                        completingString = nil

                    } else if let matchingCurrentLexeme = matchingLexemeForOpeningBracket(currentToken.type) {

                        // The current token is another opening bracket => insert matching closing for the current and
                        // previous opening bracket
                        completingString = matchingCurrentLexeme + matchingPreviousLexeme

                    } else {

                        // Insertion of a unrelated or non-bracket token => just complete the previous opening bracket
                        completingString = matchingPreviousLexeme

                    }

                } else {

                    // If a opening curly brace or nested comment bracket is followed by a line break, add another line
                    // break before the matching closing bracket.
                    if let unichar = Unicode.Scalar(char),
                       CharacterSet.newlines.contains(unichar),
                       previousToken.type == .curlyBracketOpen || previousToken.type == .nestedCommentOpen {

                        // Insertion of a newline after a curly bracket => complete\
                        // the previous opening bracket prefixed with an extra newline
                        completingString = String(unichar) + matchingPreviousLexeme

                    } else {

                        // Insertion of a character that doesn't complete a token
                        // => just complete the previous opening bracket
                        completingString = matchingPreviousLexeme

                    }
                }

            } else { completingString = nil }

            // Defer inserting the completion
            if let string = completingString {

                lastTypedToken = nil    // A completion renders the last token void
                codeStorage.cursorInsert(string: string, at: index + 1)

            }
        }
    }
}
