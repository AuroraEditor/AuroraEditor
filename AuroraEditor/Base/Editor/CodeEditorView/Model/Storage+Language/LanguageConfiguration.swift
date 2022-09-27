//
//  LanguageConfiguration.swift
//  
//
//  Created by Manuel M T Chakravarty on 03/11/2020.
//
//  Language configurations determine the linguistic characteristics that are important for the editing and display of
//  code in the respective languages, such as comment syntax, bracketing syntax, and syntax highlighting
//  characteristics.
//
//  We adapt a two-stage approach to syntax highlighting. In the first stage, basic context-free syntactic constructs
//  are being highlighted. In the second stage, contextual highlighting is performed on top of the highlighting from
//  stage one. The second stage relies on information from a code analysis subsystem, such as SourceKit.
//
//  Curent support here is only for the first stage.

import AppKit

/// Specifies the language-dependent aspects of a code editor.
///
public struct LanguageConfiguration {

    /// Tokeniser state
    enum State: TokeniserState {
        case tokenisingCode
        case tokenisingComment(Int)   // the argument gives the comment nesting depth > 0

        enum Tag: Hashable { case tokenisingCode; case tokenisingComment }

        typealias StateTag = Tag

        var tag: Tag {
            switch self {
            case .tokenisingCode:       return .tokenisingCode
            case .tokenisingComment: return .tokenisingComment
            }
        }
    }

    /// Lexeme pair for a bracketing construct
    public typealias BracketPair = (open: String, close: String)

    /// Regular expression matching strings
    public let stringRegexp: String?

    /// Regular expression matching character literals
    public let characterRegexp: String?

    /// Regular expression matching numbers
    public let numberRegexp: String?

    /// Lexeme that introduces a single line comment
    public let singleLineComment: String?

    /// A pair of lexemes that encloses a nested comment
    public let nestedComment: BracketPair?

    /// Regular expression matching all identifiers (even if they are subgroupings)
    public let identifierRegexp: String?

    /// Reserved identifiers (this does not include contextual keywords)
    public let reservedIdentifiers: [String]

    public init(stringRegexp: String?,
                characterRegexp: String?,
                numberRegexp: String?,
                singleLineComment: String?,
                nestedComment: LanguageConfiguration.BracketPair?,
                identifierRegexp: String?,
                reservedIdentifiers: [String]) {
        self.stringRegexp = stringRegexp
        self.characterRegexp = characterRegexp
        self.numberRegexp = numberRegexp
        self.singleLineComment = singleLineComment
        self.nestedComment = nestedComment
        self.identifierRegexp = identifierRegexp
        self.reservedIdentifiers = reservedIdentifiers
    }
}

extension LanguageConfiguration {

    /// Empty language configuration
    public static let none = LanguageConfiguration(stringRegexp: nil,
                                                   characterRegexp: nil,
                                                   numberRegexp: nil,
                                                   singleLineComment: nil,
                                                   nestedComment: nil,
                                                   identifierRegexp: nil,
                                                   reservedIdentifiers: [])

}

extension LanguageConfiguration {

    func incNestedComment(state: LanguageConfiguration.State) -> LanguageConfiguration.State {
        switch state {
        case .tokenisingCode:
            return .tokenisingComment(1)
        case .tokenisingComment(let number):
            return .tokenisingComment(number + 1)
        }
    }

    func decNestedComment(state: LanguageConfiguration.State) -> LanguageConfiguration.State {
        switch state {
        case .tokenisingCode:
            return .tokenisingCode
        case .tokenisingComment(let number)
            where number > 1:
            return .tokenisingComment(number - 1)
        case .tokenisingComment:
            return .tokenisingCode
        }
    }
}
