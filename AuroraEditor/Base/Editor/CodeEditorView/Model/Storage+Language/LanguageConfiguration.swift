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

    // General purpose numeric literals
    public static let binaryLit = "(?:[01]_*)+"
    public static let octalLit = "(?:[0-7]_*)+"
    public static let decimalLit = "(?:[0-9]_*)+"
    public static let hexalLit = "(?:[0-9A-Fa-f]_*)+"
    public static let optNegation = "(?:\\B-|\\b)"
    public static let exponentLit = "[eE](?:[+-])?" + decimalLit
    public static let hexponentLit = "[pP](?:[+-])?" + decimalLit

    // Identifier components following the Swift 5.4 reference
    public static let identifierHeadCharSwift
    = "["
    + "[a-zA-Z_]"
    + "[\u{00A8}\u{00AA}\u{00AD}\u{00AF}\u{00B2}–\u{00B5}\u{00B7}–\u{00BA}]"
    + "[\u{00BC}–\u{00BE}\u{00C0}–\u{00D6}\u{00D8}–\u{00F6}\u{00F8}–\u{00FF}]"
    + "[\u{0100}–\u{02FF}\u{0370}–\u{167F}\u{1681}–\u{180D}\u{180F}–\u{1DBF}]"
    + "[\u{1E00}–\u{1FFF}]"
    + "[\u{200B}–\u{200D}\u{202A}–\u{202E}\u{203F}–\u{2040}\u{2054}\u{2060}–\u{206F}]"
    + "[\u{2070}–\u{20CF}\u{2100}–\u{218F}\u{2460}–\u{24FF}\u{2776}–\u{2793}]"
    + "[\u{2C00}–\u{2DFF}\u{2E80}–\u{2FFF}]"
    + "[\u{3004}–\u{3007}\u{3021}–\u{302F}\u{3031}–\u{303F}\u{3040}–\u{D7FF}]"
    + "[\u{F900}–\u{FD3D}\u{FD40}–\u{FDCF}\u{FDF0}–\u{FE1F}\u{FE30}–\u{FE44}]"
    + "[\u{FE47}–\u{FFFD}]"
    + "[\u{10000}–\u{1FFFD}\u{20000}–\u{2FFFD}\u{30000}–\u{3FFFD}\u{40000}–\u{4FFFD}]"
    + "[\u{50000}–\u{5FFFD}\u{60000}–\u{6FFFD}\u{70000}–\u{7FFFD}\u{80000}–\u{8FFFD}]"
    + "[\u{90000}–\u{9FFFD}\u{A0000}–\u{AFFFD}\u{B0000}–\u{BFFFD}\u{C0000}–\u{CFFFD}]"
    + "[\u{D0000}–\u{DFFFD}\u{E0000}–\u{EFFFD}]"
    + "]"
    public static let identifierBodyCharSwift
    = "["
    + "[0-9]"
    + "[\u{0300}–\u{036F}\u{1DC0}–\u{1DFF}\u{20D0}–\u{20FF}\u{FE20}–\u{FE2F}]"
    + "]"

    /// Wrap a regular expression into grouping brackets.
    public static func group(_ regexp: String) -> String { "(?:" + regexp + ")" }

    /// COmpose an array of regular expressions as alternatives.
    public static func alternatives(_ alts: [String]) -> String { alts.map { group($0) }.joined(separator: "|") }
}

private let haskellReservedIds =
["case", "class", "data", "default", "deriving", "do", "else", "foreign", "if", "import", "in", "infix", "infixl",
 "infixr", "instance", "let", "module", "newtype", "of", "then", "type", "where"]

extension LanguageConfiguration {

    /// Language configuration for Haskell (including GHC extensions)
    public static let haskell = LanguageConfiguration(stringRegexp: "\"(?:\\\\\"|[^\"])*+\"",
                                                      characterRegexp: "'(?:\\\\'|[^']|\\\\[^']*+)'",
                                                      numberRegexp:
                                                        optNegation +
                                                      group(alternatives([
                                                        "0[bB]" + binaryLit,
                                                        "0[oO]" + octalLit,
                                                        "0[xX]" + hexalLit,
                                                        "0[xX]" + hexalLit + "\\." + hexalLit + hexponentLit + "?",
                                                        decimalLit + "\\." + decimalLit + exponentLit + "?",
                                                        decimalLit + exponentLit,
                                                        decimalLit
                                                      ])),
                                                      singleLineComment: "--",
                                                      nestedComment: (open: "{-", close: "-}"),
                                                      identifierRegexp:
                                                        identifierHeadCharSwift +
                                                      group(alternatives([
                                                        identifierHeadCharSwift,
                                                        identifierBodyCharSwift,
                                                        "'"
                                                      ])) + "*",
                                                      reservedIdentifiers: haskellReservedIds)

}

private let swiftReservedIds =
["actor", "associatedtype", "async", "await", "as", "break", "case", "catch", "class", "continue", "default", "defer",
 "deinit", "do", "else", "enum", "extension", "fallthrough", "fileprivate", "for", "func", "guard", "if", "import",
 "init", "inout", "internal", "in", "is", "let", "operator", "precedencegroup", "private", "protocol", "public",
 "repeat", "rethrows", "return", "self", "static", "struct", "subscript", "super", "switch", "throws", "throw", "try",
 "typealias", "var", "where", "while"]

extension LanguageConfiguration {

    /// Language configuration for Swift
    public static let swift = LanguageConfiguration(stringRegexp: "\"(?:\\\\\"|[^\"])*+\"",
                                                    characterRegexp: nil,
                                                    numberRegexp:
                                                        optNegation +
                                                    group(alternatives([
                                                        "0b" + binaryLit,
                                                        "0o" + octalLit,
                                                        "0x" + hexalLit,
                                                        "0x" + hexalLit + "\\." + hexalLit + hexponentLit + "?",
                                                        decimalLit + "\\." + decimalLit + exponentLit + "?",
                                                        decimalLit + exponentLit,
                                                        decimalLit
                                                    ])),
                                                    singleLineComment: "//",
                                                    nestedComment: (open: "/*", close: "*/"),
                                                    identifierRegexp:
                                                        alternatives([
                                                            identifierHeadCharSwift +
                                                            group(alternatives([
                                                                identifierHeadCharSwift,
                                                                identifierBodyCharSwift
                                                            ])) + "*",
                                                            "`" + identifierHeadCharSwift +
                                                            group(alternatives([
                                                                identifierHeadCharSwift,
                                                                identifierBodyCharSwift
                                                            ])) + "*`",
                                                            "\\\\$" + decimalLit,
                                                            "\\\\$" + identifierHeadCharSwift +
                                                            group(alternatives([
                                                                identifierHeadCharSwift,
                                                                identifierBodyCharSwift
                                                            ])) + "*"
                                                        ]),
                                                    reservedIdentifiers: swiftReservedIds)

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
