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

    /// Supported flavours of tokens
    enum Token {
        case roundBracketOpen
        case roundBracketClose
        case squareBracketOpen
        case squareBracketClose
        case curlyBracketOpen
        case curlyBracketClose
        case string
        case character
        case number
        case singleLineComment
        case nestedCommentOpen
        case nestedCommentClose
        case identifier
        case keyword

        var isOpenBracket: Bool {
            switch self {
            case .roundBracketOpen, .squareBracketOpen, .curlyBracketOpen, .nestedCommentOpen: return true
            default:                                                                           return false
            }
        }

        var isCloseBracket: Bool {
            switch self {
            case .roundBracketClose, .squareBracketClose, .curlyBracketClose, .nestedCommentClose: return true
            default:                                                                               return false
            }
        }

        var matchingBracket: Token? {
            switch self {
            case .roundBracketOpen:   return .roundBracketClose
            case .squareBracketOpen:  return .squareBracketClose
            case .curlyBracketOpen:   return .curlyBracketClose
            case .nestedCommentOpen:  return .nestedCommentClose
            case .roundBracketClose:  return .roundBracketOpen
            case .squareBracketClose: return .squareBracketOpen
            case .curlyBracketClose:  return .curlyBracketOpen
            case .nestedCommentClose: return .nestedCommentOpen
            default:                  return nil
            }
        }

        var isComment: Bool {
            switch self {
            case .singleLineComment:  return true
            case .nestedCommentOpen:  return true
            case .nestedCommentClose: return true
            default:                  return false
            }
        }
    }

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

    /// Yields the lexeme of the given token under this language configuration if the token has got a unique lexeme.
    func lexeme(of token: Token) -> String? {
        switch token {
        case .roundBracketOpen:   return "("
        case .roundBracketClose:  return ")"
        case .squareBracketOpen:  return "["
        case .squareBracketClose: return "]"
        case .curlyBracketOpen:   return "{"
        case .curlyBracketClose:  return "}"
        case .string:             return nil
        case .character:          return nil
        case .number:             return nil
        case .singleLineComment:  return singleLineComment
        case .nestedCommentOpen:  return nestedComment?.open
        case .nestedCommentClose: return nestedComment?.close
        case .identifier:         return nil
        case .keyword:            return nil
        }
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

    func token(_ token: LanguageConfiguration.Token)
    -> (
        token: LanguageConfiguration.Token,
        transition: ((LanguageConfiguration.State) -> LanguageConfiguration.State)?
    ) {
        return (token: token, transition: nil)
    }

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

    var tokenDictionary: TokenDictionary<LanguageConfiguration.Token, LanguageConfiguration.State> {

        var tokenDictionary = TokenDictionary<LanguageConfiguration.Token, LanguageConfiguration.State>()

        // Populate the token dictionary for the code state (tokenising plain code)
        var codeTokenDictionary = [
            TokenPattern: TokenAction<LanguageConfiguration.Token, LanguageConfiguration.State>
        ]()

        codeTokenDictionary.updateValue(token(.roundBracketOpen), forKey: .string("("))
        codeTokenDictionary.updateValue(token(.roundBracketClose), forKey: .string(")"))
        codeTokenDictionary.updateValue(token(.squareBracketOpen), forKey: .string("["))
        codeTokenDictionary.updateValue(token(.squareBracketClose), forKey: .string("]"))
        codeTokenDictionary.updateValue(token(.curlyBracketOpen), forKey: .string("{"))
        codeTokenDictionary.updateValue(token(.curlyBracketClose), forKey: .string("}"))
        if let lexeme = stringRegexp { codeTokenDictionary.updateValue(token(.string), forKey: .pattern(lexeme)) }
        if let lexeme = characterRegexp { codeTokenDictionary.updateValue(token(.character), forKey: .pattern(lexeme)) }
        if let lexeme = numberRegexp { codeTokenDictionary.updateValue(token(.number), forKey: .pattern(lexeme)) }
        if let lexeme = singleLineComment {
            codeTokenDictionary.updateValue(token(Token.singleLineComment), forKey: .string(lexeme))
        }
        if let lexemes = nestedComment {
            codeTokenDictionary.updateValue((token: .nestedCommentOpen, transition: incNestedComment),
                                            forKey: .string(lexemes.open))
            codeTokenDictionary.updateValue((token: .nestedCommentClose, transition: decNestedComment),
                                            forKey: .string(lexemes.close))
        }
        if let lexeme = identifierRegexp {
            codeTokenDictionary.updateValue(token(Token.identifier), forKey: .pattern(lexeme))
        }
        for reserved in reservedIdentifiers {
            codeTokenDictionary.updateValue(token(.keyword), forKey: .word(reserved))
        }

        tokenDictionary.updateValue(codeTokenDictionary, forKey: .tokenisingCode)

        // Populate the token dictionary for the comment state (tokenising within a nested comment)
        var commentTokenDictionary = [
            TokenPattern: TokenAction<LanguageConfiguration.Token, LanguageConfiguration.State>
        ]()

        if let lexemes = nestedComment {
            commentTokenDictionary.updateValue((token: .nestedCommentOpen, transition: incNestedComment),
                                               forKey: .string(lexemes.open))
            commentTokenDictionary.updateValue((token: .nestedCommentClose, transition: decNestedComment),
                                               forKey: .string(lexemes.close))
        }

        tokenDictionary.updateValue(commentTokenDictionary, forKey: .tokenisingComment)

        return tokenDictionary
    }
}
