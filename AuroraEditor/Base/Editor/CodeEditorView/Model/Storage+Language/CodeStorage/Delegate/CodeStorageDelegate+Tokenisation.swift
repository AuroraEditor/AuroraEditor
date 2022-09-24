//
//  CodeStorageDelegate+Tokenisation.swift
//  AuroraEditor
//
//  Created by TAY KAI QUAN on 18/9/22.
//  Copyright © 2022 Aurora Company. All rights reserved.
//

import AppKit

extension CodeStorageDelegate {

    /// Tokenise the substring of the given text storage that contains the specified lines and set token attributes as
    /// needed.
    ///
    /// - Parameters:
    ///   - originalRange: The character range that contains all characters that have changed.
    ///   - textStorage: The text storage that contains the changed characters.
    ///
    /// Tokenisation happens at line granularity. Hence, the range is correspondingly extended.
    func tokeniseAttributesFor( // swiftlint:disable:this function_body_length
        range originalRange: NSRange,
        in textStorage: NSTextStorage
    ) {
        guard let codeStorage = textStorage as? CodeStorage else { return }

        func tokeniseAndUpdateInfo( // swiftlint:disable:this function_body_length
            for line: Int,
            commentDepth: inout Int,
            lastCommentStart: inout Int?
        ) {

            if let lineRange = lineMap.lookup(line: line)?.range {

                // Remove any existing `.comment` attribute on this line
                textStorage.removeAttribute(.comment, range: lineRange)

                // Collect all tokens on this line.
                // (NB: In the block, we are not supposed to mutate outside
                // the attribute range; hence, we only collect tokens.)
                var tokens = [(token: LanguageConfiguration.Token, range: NSRange)]()
                codeStorage.enumerateTokens(in: lineRange) { (tokenValue, range, _) in

                    tokens.append((token: tokenValue, range: range))

                    if visualDebugging {

                        textStorage.addAttribute(.underlineColor, value: visualDebuggingTokenColour, range: range)
                        if range.length > 0 {
                            textStorage.addAttribute(.underlineStyle,
                                                     value: NSNumber(value: NSUnderlineStyle.double.rawValue),
                                                     range: NSRange(location: range.location, length: 1))
                        }
                        if range.length > 1 {
                            textStorage.addAttribute(.underlineStyle,
                                                     value: NSNumber(value: NSUnderlineStyle.single.rawValue),
                                                     range: NSRange(location: range.location + 1,
                                                                    length: range.length - 1))
                        }
                    }
                }

                var lineInfo = LineInfo(commentDepthStart: commentDepth,
                                        commentDepthEnd: 0,
                                        roundBracketDiff: 0,
                                        squareBracketDiff: 0,
                                        curlyBracketDiff: 0)
            tokenLoop: for token in tokens {

                switch token.token {

                case .roundBracketOpen:
                    lineInfo.roundBracketDiff += 1

                case .roundBracketClose:
                    lineInfo.roundBracketDiff -= 1

                case .squareBracketOpen:
                    lineInfo.squareBracketDiff += 1

                case .squareBracketClose:
                    lineInfo.squareBracketDiff -= 1

                case .curlyBracketOpen:
                    lineInfo.curlyBracketDiff += 1

                case .curlyBracketClose:
                    lineInfo.curlyBracketDiff -= 1

                case .singleLineComment:  // set comment attribute from token start token to the end of this line
                    let commentStart = token.range.location,
                        commentRange = NSRange(location: commentStart, length: NSMaxRange(lineRange) - commentStart)
                    textStorage.addAttribute(.comment, value: CommentStyle.singleLineComment, range: commentRange)

                    // the rest of the tokens are ignored as they are commented out and we'll rescan on change
                    break tokenLoop

                case .nestedCommentOpen:
                    // start of an outermost nested comment
                    if commentDepth == 0 { lastCommentStart = token.range.location }
                    commentDepth += 1

                case .nestedCommentClose:
                    if commentDepth > 0 {

                        commentDepth -= 1

                        // If we just closed an outermost nested comment, attribute the comment range
                        if let start = lastCommentStart, commentDepth == 0 {
                            textStorage.addAttribute(.comment,
                                                     value: CommentStyle.nestedComment,
                                                     range: NSRange(location: start,
                                                                    length: NSMaxRange(token.range) - start))
                            lastCommentStart = nil
                        }
                    }

                default:
                    break
                }
            }

                // If the line ends while we are still in an open comment,
                // we need a comment attribute up to the end of the line
                if let start = lastCommentStart, commentDepth > 0 {

                    textStorage.addAttribute(.comment,
                                             value: CommentStyle.nestedComment,
                                             range: NSRange(location: start, length: NSMaxRange(lineRange) - start))

                }

                // Retain computed line information
                lineInfo.commentDepthEnd = commentDepth
                lineMap.setInfoOf(line: line, to: lineInfo)
            }
        }

        guard let tokeniser = tokeniser else { return }

        // Extend the range to line boundaries. Because we cannot parse partial tokens, we at least need to go to word
        // boundaries, but because we have line bounded constructs like comments to the end of the line and it is easier
        // to determine the line boundaries, we use those.
        let lines = lineMap.linesContaining(range: originalRange),
            range = lineMap.charRangeOf(lines: lines)

        // Determine the comment depth as determined by the preceeeding code. This is needed to determine the correct
        // tokeniser and to compute attribute information from the resulting tokens. NB: We need to get that info from
        // the previous line, because the line info of the current line was set to `nil` during updating the line map.
        let initialCommentDepth = lineMap.lookup(line: lines.startIndex - 1)?.info?.commentDepthEnd ?? 0

        // Set the token attribute in range.
        let initialTokeniserState: LanguageConfiguration.State = initialCommentDepth > 0
        ? .tokenisingComment(initialCommentDepth)
        : .tokenisingCode

        textStorage.tokeniseAndSetTokenAttribute(attribute: .token,
                                                 with: tokeniser,
                                                 state: initialTokeniserState,
                                                 in: range)

        // For all lines in range, collect the tokens line by line, while keeping track of nested comments
        //
        // - `lastCommentStart` keeps track of the last start of an *outermost* nested comment.
        var commentDepth = initialCommentDepth
        var lastCommentStart = initialCommentDepth > 0
        ? lineMap.lookup(line: lines.startIndex)?.range.location
        : nil

        for line in lines {
            tokeniseAndUpdateInfo(for: line, commentDepth: &commentDepth, lastCommentStart: &lastCommentStart)
        }

        // Continue to re-process line by line until there is no longer a change in the comment depth before and after
        // re-processing
        var currentLine = lines.endIndex
        var highlightingRange = range
    trailingLineLoop: while currentLine < lineMap.lines.count {

        if let lineEntry = lineMap.lookup(line: currentLine) {

            // If this line has got a line info entry and the expected comment depth at the start of the line matches
            // the current comment depth, we reached the end of the range of lines affected by this edit
            // => break the loop
            if let depth = lineEntry.info?.commentDepthStart, depth == commentDepth { break trailingLineLoop }

            // Re-tokenise line
            let initialTokeniserState: LanguageConfiguration.State = commentDepth > 0
            ? .tokenisingComment(commentDepth)
            : .tokenisingCode

            textStorage.tokeniseAndSetTokenAttribute(attribute: .token,
                                                     with: tokeniser,
                                                     state: initialTokeniserState,
                                                     in: lineEntry.range)

            // Collect the tokens and update line info
            tokeniseAndUpdateInfo(for: currentLine, commentDepth: &commentDepth, lastCommentStart: &lastCommentStart)

            // Keep track of the trailing range for debugging purpose
            highlightingRange = NSUnionRange(highlightingRange, lineEntry.range)

        }
        currentLine += 1
    }

        if visualDebugging {
            textStorage.addAttribute(.backgroundColor, value: visualDebuggingTrailingColour, range: highlightingRange)
            textStorage.addAttribute(.backgroundColor, value: visualDebuggingLinesColour, range: range)
        }
    }
}
