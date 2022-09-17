//
//  CodeStorageDelegate.swift
//  
//
//  Created by Manuel M T Chakravarty on 29/09/2020.
//
//  'NSTextStorageDelegate' for code views compute, collect, store, and update additional information about the text
//  stored in the 'NSTextStorage' that they serve. This is needed to quickly navigate the text (e.g., at which character
//  position does a particular line start) and to support code-specific rendering (e.g., syntax highlighting).

// FIXME: the aliases ought to be moved to some central place for os impedance matching
#if os(iOS)
import UIKit
#elseif os(macOS)
import AppKit
#endif

// MARK: -
// MARK: Visual debugging support

// FIXME: It should be possible to enable this via a defaults setting.
private let visualDebugging               = false
private let visualDebuggingEditedColour   = OSColor(red: 0.5, green: 1.0, blue: 0.5, alpha: 0.3)
private let visualDebuggingLinesColour    = OSColor(red: 0.5, green: 0.5, blue: 1.0, alpha: 0.3)
private let visualDebuggingTrailingColour = OSColor(red: 1.0, green: 0.5, blue: 0.5, alpha: 0.3)
private let visualDebuggingTokenColour    = OSColor(red: 1.0, green: 0.0, blue: 0.0, alpha: 0.5)

// MARK: -
// MARK: Tokens

// Custom token attributes
//
extension NSAttributedString.Key {

  /// Custom attribute marking comment ranges.
  ///
  static let comment = NSAttributedString.Key("comment")

  /// Custom attribute marking lexical tokens.
  ///
  static let token = NSAttributedString.Key("token")
}

/// The supported comment styles.
///
enum CommentStyle {
  case singleLineComment
  case nestedComment
}

/// Information that is tracked on a line by line basis in the line map.
///
/// NB: We need the comment depth at the start and the end of each line as, during editing, lines are replaced in the
///     line map before comment attributes are recalculated. During this replacement, we lose the line info of all the
///     replaced lines.
///
struct LineInfo {

  /// Structure characterising a bundle of messages reported for a single line. It features a stable identity to be able
  /// to associate display information in separate structures.
  ///
  /// NB: We don't identify a message bundle by the line number on which it appears, because edits further up can
  ///     increase and decrease the line number of a given bundle. We need a stable identifier.
  ///
  struct MessageBundle: Identifiable {
    let id: UUID
    var messages: [Message]

    init(messages: [Message]) {
      self.id       = UUID()
      self.messages = messages
    }
  }

  var commentDepthStart: Int   // nesting depth for nested comments at the start of this line
  var commentDepthEnd: Int   // nesting depth for nested comments at the end of this line

  // FIXME: we are not currently using the following three variables (they are maintained, but they are never useful).
  var roundBracketDiff: Int   // increase or decrease of the nesting level of round brackets on this line
  var squareBracketDiff: Int   // increase or decrease of the nesting level of square brackets on this line
  var curlyBracketDiff: Int   // increase or decrease of the nesting level of curly brackets on this line

  /// The messages reported for this line.
  ///
  /// NB: The bundle may be non-nil, but still contain no messages (after all messages have been removed).
  ///
  var messages: MessageBundle?
}

// MARK: -
// MARK: Delegate class

class CodeStorageDelegate: NSObject, NSTextStorageDelegate {

  let language: LanguageConfiguration
  private let tokeniser: Tokeniser<LanguageConfiguration.Token, LanguageConfiguration.State>? // cache the tokeniser

  private(set) var lineMap = LineMap<LineInfo>(string: "")

  /// The message bundle IDs that got invalidated by the last editing operation because the lines to which they were
  /// attached got changed.
  ///
  private(set) var lastEvictedMessageIDs: [LineInfo.MessageBundle.ID] = []

  /// If the last text change was a one-character addition, which completed a token, then that token is remembered here
  /// together with its range until the next text change.
  ///
  private var lastTypedToken: (type: LanguageConfiguration.Token, range: NSRange)?

  /// Flag that indicates that the current editing round is for a one-character addition to the text. This property
  /// needs to be determined before attribute fixing and the like.
  ///
  private var processingOneCharacterEdit: Bool?

  init(with language: LanguageConfiguration) {
    self.language  = language
    self.tokeniser = NSMutableAttributedString.tokeniser(for: language.tokenDictionary)
    super.init()
  }

  func textStorage(_ textStorage: NSTextStorage,
                   willProcessEditing editedMask: TextStorageEditActions,
                   range editedRange: NSRange,
                   changeInLength delta: Int) {
    processingOneCharacterEdit = delta == 1 && editedRange.length == 1
  }

  // NB: The choice of `didProcessEditing` versus `willProcessEditing` is crucial on macOS. The reason is that
  //     the text storage performs "attribute fixing" between `willProcessEditing` and `didProcessEditing`. If we
  //     modify attributes outside of `editedRange` (which we often do), then this triggers the movement of the
  //     current selection to the end of the entire text.
  //
  //     By doing the highlighting work *after* attribute fixing, we avoid affecting the selection. However, it now
  //     becomes *very* important to (a) refrain from any character changes and (b) from any attribute changes that
  //     result in attributes that need to be fixed; otherwise, we end up with an inconsistent attributed string.
  //     (In particular, changing the font attribute at this point is potentially dangerous.)
  func textStorage(_ textStorage: NSTextStorage,
                   didProcessEditing editedMask: TextStorageEditActions,
                   range editedRange: NSRange, // Apple docs are incorrect here: this is the range *after* editing
                   changeInLength delta: Int) {
    guard let codeStorage = textStorage as? CodeStorage else { return }

    // If only attributes change, the line map and syntax highlighting remains the same => nothing for us to do
    guard editedMask.contains(.editedCharacters) else { return }

    if visualDebugging {
      let wholeTextRange = NSRange(location: 0, length: textStorage.length)
      textStorage.removeAttribute(.backgroundColor, range: wholeTextRange)
      textStorage.removeAttribute(.underlineColor, range: wholeTextRange)
      textStorage.removeAttribute(.underlineStyle, range: wholeTextRange)
    }

    // Determine the ids of message bundles that are removed by this edit.
    let lines = lineMap.linesAffected(by: editedRange, changeInLength: delta)
    lastEvictedMessageIDs = lines.compactMap { lineMap.lookup(line: $0)?.info?.messages?.id }

    lineMap.updateAfterEditing(string: textStorage.string, range: editedRange, changeInLength: delta)
    tokeniseAttributesFor(range: editedRange, in: textStorage)

    if visualDebugging {
      textStorage.addAttribute(.backgroundColor, value: visualDebuggingEditedColour, range: editedRange)
    }

    // If a single character was added, process token-level completion steps.
    if delta == 1 && processingOneCharacterEdit == true {
      tokenCompletion(for: codeStorage, at: editedRange.location)
    }
    processingOneCharacterEdit = nil
  }
}

// MARK: -
// MARK: Tokenisation

extension CodeStorageDelegate {

  /// Tokenise the substring of the given text storage that contains the specified lines and set token attributes as
  /// needed.
  ///
  /// - Parameters:
  ///   - originalRange: The character range that contains all characters that have changed.
  ///   - textStorage: The text storage that contains the changed characters.
  ///
  /// Tokenisation happens at line granularity. Hence, the range is correspondingly extended.
  ///
  func tokeniseAttributesFor(range originalRange: NSRange, in textStorage: NSTextStorage) {
    guard let codeStorage = textStorage as? CodeStorage else { return }

    func tokeniseAndUpdateInfo(for line: Int, commentDepth: inout Int, lastCommentStart: inout Int?) {

      if let lineRange = lineMap.lookup(line: line)?.range {

        // Remove any existing `.comment` attribute on this line
        textStorage.removeAttribute(.comment, range: lineRange)

        // Collect all tokens on this line.
        // (NB: In the block, we are not supposed to mutate outside the attribute range; hence, we only collect tokens.)
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
                                       range: NSRange(location: range.location + 1, length: range.length - 1))
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
            break tokenLoop   // the rest of the tokens are ignored as they are commented out and we'll rescan on change

          case .nestedCommentOpen:
            if commentDepth == 0 { lastCommentStart = token.range.location }    // start of an outermost nested comment
            commentDepth += 1

          case .nestedCommentClose:
            if commentDepth > 0 {

              commentDepth -= 1

              // If we just closed an outermost nested comment, attribute the comment range
              if let start = lastCommentStart, commentDepth == 0 {
                textStorage.addAttribute(.comment,
                                         value: CommentStyle.nestedComment,
                                         range: NSRange(location: start, length: NSMaxRange(token.range) - start))
                lastCommentStart = nil
              }
            }

          default:
            break
          }
        }

        // If the line ends while we are still in an open comment, we need a comment attribute up to the end of the line
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
    // boundaries, but because we have line bounded constructs like comments to the end of the line and it is easier to
    // determine the line boundaries, we use those.
    let lines = lineMap.linesContaining(range: originalRange),
        range = lineMap.charRangeOf(lines: lines)

    // Determine the comment depth as determined by the preceeeding code. This is needed to determine the correct
    // tokeniser and to compute attribute information from the resulting tokens. NB: We need to get that info from
    // the previous line, because the line info of the current line was set to `nil` during updating the line map.
    let initialCommentDepth  = lineMap.lookup(line: lines.startIndex - 1)?.info?.commentDepthEnd ?? 0

    // Set the token attribute in range.
    let initialTokeniserState: LanguageConfiguration.State
      = initialCommentDepth > 0 ? .tokenisingComment(initialCommentDepth) : .tokenisingCode
    textStorage.tokeniseAndSetTokenAttribute(attribute: .token,
                                             with: tokeniser,
                                             state: initialTokeniserState,
                                             in: range)

    // For all lines in range, collect the tokens line by line, while keeping track of nested comments
    //
    // - `lastCommentStart` keeps track of the last start of an *outermost* nested comment.
    //
    var commentDepth     = initialCommentDepth
    var lastCommentStart = initialCommentDepth > 0 ? lineMap.lookup(line: lines.startIndex)?.range.location : nil
    for line in lines {
      tokeniseAndUpdateInfo(for: line, commentDepth: &commentDepth, lastCommentStart: &lastCommentStart)
    }

    // Continue to re-process line by line until there is no longer a change in the comment depth before and after
    // re-processing
    //
    var currentLine       = lines.endIndex
    var highlightingRange = range
    trailingLineLoop: while currentLine < lineMap.lines.count {

      if let lineEntry = lineMap.lookup(line: currentLine) {

        // If this line has got a line info entry and the expected comment depth at the start of the line matches
        // the current comment depth, we reached the end of the range of lines affected by this edit => break the loop
        if let depth = lineEntry.info?.commentDepthStart, depth == commentDepth { break trailingLineLoop }

        // Re-tokenise line
        let initialTokeniserState: LanguageConfiguration.State
          = commentDepth > 0 ? .tokenisingComment(commentDepth) : .tokenisingCode
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

// MARK: -
// MARK: Token completion

extension CodeStorageDelegate {

  /// Handle token completion actions after a single character was inserted.
  ///
  /// - Parameters:
  ///   - textStorage: The text storage where the edit action occured.
  ///   - index: The location within the text storage where the single chracter was inserted.
  ///
  /// Any change to the `textStorage` is deferred, so that this function can also be used in the middle of an
  /// in-progress, but not yet completed edit.
  ///
  func tokenCompletion(for codeStorage: CodeStorage, at index: Int) {

    /// If the given token is an opening bracket, return the lexeme of its matching closing bracket.
    ///
    func matchingLexemeForOpeningBracket(_ token: LanguageConfiguration.Token) -> String? {
      if token.isOpenBracket, let matching = token.matchingBracket, let lexeme = language.lexeme(of: matching) {
        return lexeme
      } else {
        return nil
      }
    }

    /// Determine whether the ranges of the two tokens are overlapping.
    ///
    func overlapping(_ previousToken: (type: LanguageConfiguration.Token, range: NSRange),
                     _ currentToken: (type: LanguageConfiguration.Token, range: NSRange)?) -> Bool {
      if let currentToken = currentToken {
        return NSIntersectionRange(previousToken.range, currentToken.range).length != 0
      } else { return false }
    }

    let string             = codeStorage.string,
        char               = string.utf16[string.index(string.startIndex, offsetBy: index)],
        previousTypedToken = lastTypedToken,
        currentTypedToken: (type: LanguageConfiguration.Token, range: NSRange)?

    // Determine the token (if any) that the right now inserted character belongs to
    currentTypedToken = codeStorage.token(at: index)

    lastTypedToken = currentTypedToken    // this is the default outcome, unless explicitly overridden below

    // The just entered character is right after the previous token and it doesn't belong to a token overlapping with
    // the previous token
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

            // The current token is another opening bracket => insert matching closing for the current and previous
            // opening bracket
            completingString = matchingCurrentLexeme + matchingPreviousLexeme

          } else {

            // Insertion of a unrelated or non-bracket token => just complete the previous opening bracket
            completingString = matchingPreviousLexeme

          }

        } else {

          // If a opening curly brace or nested comment bracket is followed by a line break, add another line break
          // before the matching closing bracket.
          if let unichar = Unicode.Scalar(char),
             CharacterSet.newlines.contains(unichar),
             previousToken.type == .curlyBracketOpen || previousToken.type == .nestedCommentOpen {

            // Insertion of a newline after a curly bracket => complete\
            // the previous opening bracket prefixed with an extra newline
            completingString = String(unichar) + matchingPreviousLexeme

          } else {

          // Insertion of a character that doesn't complete a token => just complete the previous opening bracket
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

// MARK: -
// MARK: Messages

extension CodeStorageDelegate {

  /// Add the given message to the line info of the line where the message is located.
  ///
  /// - Parameter message: The message to add.
  /// - Returns: The message bundle to which the message was added, or `nil` if the line for which the message is
  ///     intended doesn't exist.
  ///
  /// NB: Ignores messages for lines that do not exist in the line map. A message may not be added to multiple lines.
  ///
  func add(message: Located<Message>) -> LineInfo.MessageBundle? {
    guard var info = lineMap.lookup(line: message.location.line)?.info else { return nil }

    if info.messages != nil {

      // Add a message to an existing message bundle for this line
      info.messages?.messages.append(message.entity)

    } else {

      // Create a new message bundle for this line with the new message
      info.messages = LineInfo.MessageBundle(messages: [message.entity])

    }
    lineMap.setInfoOf(line: message.location.line, to: info)
    return info.messages
  }

  /// Remove the given message from the line info in which it is located. This function is quite expensive.
  ///
  /// - Parameter message: The message to remove.
  /// - Returns: The updated message bundle from which the message was removed together with the line where it occured,
  ///     or `nil` if the message occurs in no line bundle.
  ///
  /// NB: Ignores messages that do not exist in the line map. It is considered an error if a message exists at multiple
  ///     lines. In this case, the occurences at the first such line will be used.
  ///
  func remove(message: Message) -> (LineInfo.MessageBundle, Int)? {

    for line in lineMap.lines.indices {

      if var info = lineMap.lines[line].info {
        if let idx = info.messages?.messages.firstIndex(of: message) {

          info.messages?.messages.remove(at: idx)
          lineMap.setInfoOf(line: line, to: info)
          if let messages = info.messages { return (messages, line) } else { return nil }

        }
      }
    }
    return nil
  }

  /// Returns the message bundle associated with the given line if it exists.
  ///
  /// - Parameter line: The line for which we want to know the associated message bundle.
  /// - Returns: The message bundle associated with the given line or `nil`.
  ///
  /// NB: In case that the line does not exist, an empty array is returned.
  ///
  func messages(at line: Int) -> LineInfo.MessageBundle? { return lineMap.lookup(line: line)?.info?.messages }

  /// Remove all messages associated with a given line.
  ///
  /// - Parameter line: The line whose messages ought ot be removed.
  ///
  func removeMessages(at line: Int) {
    guard var info = lineMap.lookup(line: line)?.info else { return }

    info.messages = nil
    lineMap.setInfoOf(line: line, to: info)
  }
}
