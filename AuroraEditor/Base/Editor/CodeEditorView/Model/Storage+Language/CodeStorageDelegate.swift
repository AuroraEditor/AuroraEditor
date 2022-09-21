//
//  CodeStorageDelegate.swift
//  
//
//  Created by Manuel M T Chakravarty on 29/09/2020.
//
//  'NSTextStorageDelegate' for code views compute, collect, store, and update additional information about the text
//  stored in the 'NSTextStorage' that they serve. This is needed to quickly navigate the text (e.g., at which character
//  position does a particular line start) and to support code-specific rendering (e.g., syntax highlighting).

import AppKit

// MARK: - Visual debugging support

// FIXME: It should be possible to enable this via a defaults setting.
let visualDebugging = false
let visualDebuggingEditedColour = OSColor(red: 0.5, green: 1.0, blue: 0.5, alpha: 0.3)
let visualDebuggingLinesColour = OSColor(red: 0.5, green: 0.5, blue: 1.0, alpha: 0.3)
let visualDebuggingTrailingColour = OSColor(red: 1.0, green: 0.5, blue: 0.5, alpha: 0.3)
let visualDebuggingTokenColour = OSColor(red: 1.0, green: 0.0, blue: 0.0, alpha: 0.5)

// MARK: - Tokens

// Custom token attributes
extension NSAttributedString.Key {

    /// Custom attribute marking comment ranges.
    static let comment = NSAttributedString.Key("comment")

    /// Custom attribute marking lexical tokens.
    static let token = NSAttributedString.Key("token")
}

/// The supported comment styles.
enum CommentStyle {
    case singleLineComment
    case nestedComment
}

/// Information that is tracked on a line by line basis in the line map.
///
/// NB: We need the comment depth at the start and the end of each line as, during editing, lines are replaced in the
///    line map before comment attributes are recalculated. During this replacement, we lose the line info of all the
///    replaced lines.
struct LineInfo {

    /// Structure characterising a bundle of messages reported for a single line. It features
    /// a stable identity to be able to associate display information in separate structures.
    ///
    /// NB: We don't identify a message bundle by the line number on which it appears, because edits further up can
    ///    increase and decrease the line number of a given bundle. We need a stable identifier.
    struct MessageBundle: Identifiable {
        let id: UUID
        var messages: [Message]

        init(messages: [Message]) {
            self.id = UUID()
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
    var messages: MessageBundle?
}

// MARK: - Delegate class
class CodeStorageDelegate: NSObject, NSTextStorageDelegate {

    let language: LanguageConfiguration
    let tokeniser: Tokeniser<LanguageConfiguration.Token, LanguageConfiguration.State>? // cache the tokeniser

    var lineMap = LineMap<LineInfo>(string: "")

    /// The message bundle IDs that got invalidated by the last editing operation because the lines to which they were
    /// attached got changed.
    var lastEvictedMessageIDs: [LineInfo.MessageBundle.ID] = []

    /// If the last text change was a one-character addition, which completed a token, then
    /// that token is remembered here together with its range until the next text change.
    var lastTypedToken: (type: LanguageConfiguration.Token, range: NSRange)?

    /// Flag that indicates that the current editing round is for a one-character addition to the text. This property
    /// needs to be determined before attribute fixing and the like.
    private var processingOneCharacterEdit: Bool?

    init(with language: LanguageConfiguration) {
        self.language = language
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
