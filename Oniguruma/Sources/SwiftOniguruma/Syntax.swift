//
//  Syntax.swift
//  
//
//  Created by Gavin Mao on 3/27/21.
//

import Oniguruma

/**
 Oniguruma syntax wrapper.
 This type also comes with static wrapper for oniguruma build-in syntaxes, i.e. `Syntax.oniguruma`, `Syntax.default`.
 */
public class Syntax {
    internal typealias OnigSyntaxPtr = UnsafeMutablePointer<OnigSyntaxType>
    internal var rawValue: OnigSyntaxPtr!

    /**
     This `OnigSyntaxType` is owned by this object, for oniguruma built-in syntaxes, we only carry the pointer to them.
     */
    private var ownedSyntax: OnigSyntaxType?

    /**
     Create a empty syntax.
     */
    public init() {
        self.ownedSyntax = OnigSyntaxType()
        withUnsafeMutablePointer(to: &self.ownedSyntax!) {
            self.rawValue = $0
        }
    }

    /**
     Copy from other syntax.
     - Parameter other: other syntax to copy the syntax from.
     */
    public convenience init(from other: Syntax) {
        self.init()
        onig_copy_syntax(self.rawValue, other.rawValue)
    }

    /**
     Create a `Syntax` with a pointer to oniguruma syntax object. If it's `nil`, will create a empty syntax.
     - Parameter rawValue: The pointer to oniguruma syntax object.
     */
    internal init(rawValue: OnigSyntaxPtr?) {
        if let rawValue = rawValue {
            self.rawValue = rawValue
        } else {
            self.ownedSyntax = OnigSyntaxType()
            withUnsafeMutablePointer(to: &self.ownedSyntax!) {
                self.rawValue = $0
            }
        }
    }

    /// Plain text syntax
    public static let asis = Syntax(rawValue: &OnigSyntaxASIS)

    /// POSIX Basic RE syntax
    public static let posixBasic = Syntax(rawValue: &OnigSyntaxPosixBasic)

    /// POSIX Extended RE syntax
    public static var posixExtended = Syntax(rawValue: &OnigSyntaxPosixExtended)

    /// Emacs syntax
    public static var emacs = Syntax(rawValue: &OnigSyntaxEmacs)

    /// Grep syntax
    public static var grep = Syntax(rawValue: &OnigSyntaxGrep)

    /// GNU regex syntax
    public static var gnuRegex = Syntax(rawValue: &OnigSyntaxGnuRegex)

    /// Java syntax
    public static var java = Syntax(rawValue: &OnigSyntaxJava)

    /// Perl syntax
    public static var perl = Syntax(rawValue: &OnigSyntaxPerl)

    /// Perl + named group syntax
    public static var perlNg = Syntax(rawValue: &OnigSyntaxPerl_NG)

    /// Ruby syntax
    public static var ruby = Syntax(rawValue: &OnigSyntaxRuby)

    /// Oniguruma syntax
    public static var oniguruma = Syntax(rawValue: &OnigSyntaxOniguruma)

    /// Default syntax
    public static var `default`: Syntax {
        get {
            return Syntax(rawValue: OnigDefaultSyntax)
        }

        set {
            onig_set_default_syntax(newValue.rawValue)
        }
    }

    /**
     Get or set the syntax options for this syntax.
     */
    public var options: Regex.Options {
        get {
            return Regex.Options(rawValue: onig_get_syntax_options(self.rawValue))
        }

        set {
            self.convertToOwnedIfNeeded()
            onig_set_syntax_options(self.rawValue, newValue.rawValue)
        }
    }

    /**
     If this syntax is not owned (which means only a pointer is set), convert it to a owned
     */
    private func convertToOwnedIfNeeded() {
        if self.ownedSyntax != nil {
            // already owns a syntax
            return
        }

        self.ownedSyntax = OnigSyntaxType()
        onig_copy_syntax(&self.ownedSyntax!, self.rawValue)
        withUnsafeMutablePointer(to: &self.ownedSyntax!) {
            self.rawValue = $0
        }
    }
}

/**
 Syntax operators
 */
extension Syntax {
    public struct Operators: OptionSet {
        public let rawValue: UInt64

        public init(rawValue: UInt64) {
            self.rawValue = rawValue
        }

        public init(onigSyntaxOp: OnigUInt, onigSyntaxOp2: OnigUInt) {
            self.rawValue = UInt64(onigSyntaxOp) | (UInt64(onigSyntaxOp2) << 32)
        }

        public static let variableMetaCharacters = Syntax.Operators(
            rawValue: UInt64(ONIG_SYN_OP_VARIABLE_META_CHARACTERS)
        )

        /// .
        public static let dotAnychar = Syntax.Operators(rawValue: UInt64(ONIG_SYN_OP_DOT_ANYCHAR))

        /// *
        public static let asteriskZeroInf = Syntax.Operators(rawValue: UInt64(ONIG_SYN_OP_ASTERISK_ZERO_INF))

        public static let escAsteriskZeroInf = Syntax.Operators(rawValue: UInt64(ONIG_SYN_OP_ESC_ASTERISK_ZERO_INF))

        /// +
        public static let plusOneInf = Syntax.Operators(rawValue: UInt64(ONIG_SYN_OP_PLUS_ONE_INF))

        public static let escPlusOneInf = Syntax.Operators(rawValue: UInt64(ONIG_SYN_OP_ESC_PLUS_ONE_INF))

        /// ?
        public static let qmarkZeroOne = Syntax.Operators(rawValue: UInt64(ONIG_SYN_OP_QMARK_ZERO_ONE))

        public static let escQmarkZeroOne = Syntax.Operators(rawValue: UInt64(ONIG_SYN_OP_ESC_QMARK_ZERO_ONE))

        /// {lower,upper}
        public static let braceInterval = Syntax.Operators(rawValue: UInt64(ONIG_SYN_OP_BRACE_INTERVAL))

        /// \{lower,upper\}
        public static let escBraceInterval = Syntax.Operators(rawValue: UInt64(ONIG_SYN_OP_ESC_BRACE_INTERVAL))

        /// |
        public static let vbarAlt = Syntax.Operators(rawValue: UInt64(ONIG_SYN_OP_VBAR_ALT))

        /// \|
        public static let escVbarAlt = Syntax.Operators(rawValue: UInt64(ONIG_SYN_OP_ESC_VBAR_ALT))

        /// (...)
        public static let lparenSubexp = Syntax.Operators(rawValue: UInt64(ONIG_SYN_OP_LPAREN_SUBEXP))

        /// \(...\)
        public static let escLparenSubexp = Syntax.Operators(rawValue: UInt64(ONIG_SYN_OP_ESC_LPAREN_SUBEXP))

        /// \A, \Z, \z
        public static let escAzBufAnchor = Syntax.Operators(rawValue: UInt64(ONIG_SYN_OP_ESC_AZ_BUF_ANCHOR))

        /// \G
        public static let escCapitalGBeginAnchor = Syntax.Operators(
            rawValue: UInt64(ONIG_SYN_OP_ESC_CAPITAL_G_BEGIN_ANCHOR)
        )

        /// \num
        public static let decimalBackref = Syntax.Operators(rawValue: UInt64(ONIG_SYN_OP_DECIMAL_BACKREF))

        /// [...]
        public static let bracketCc = Syntax.Operators(rawValue: UInt64(ONIG_SYN_OP_BRACKET_CC))

        /// \w, \W
        public static let escWWord = Syntax.Operators(rawValue: UInt64(ONIG_SYN_OP_ESC_W_WORD))

        /// \<. \>
        public static let escLtgtWordBeginEnd = Syntax.Operators(rawValue: UInt64(ONIG_SYN_OP_ESC_LTGT_WORD_BEGIN_END))

        /// \b, \B
        public static let escBWordBound = Syntax.Operators(rawValue: UInt64(ONIG_SYN_OP_ESC_B_WORD_BOUND))

        /// \s, \S
        public static let escSWhiteSpace = Syntax.Operators(rawValue: UInt64(ONIG_SYN_OP_ESC_S_WHITE_SPACE))

        /// \d, \D
        public static let escDDigit = Syntax.Operators(rawValue: UInt64(ONIG_SYN_OP_ESC_D_DIGIT))

        /// ^, $
        public static let lineAnchor = Syntax.Operators(rawValue: UInt64(ONIG_SYN_OP_LINE_ANCHOR))

        /// [:xxxx:]
        public static let posixBracket = Syntax.Operators(rawValue: UInt64(ONIG_SYN_OP_POSIX_BRACKET))

        /// ??,*?,+?,{n,m}?
        public static let qmarkNonGreedy = Syntax.Operators(rawValue: UInt64(ONIG_SYN_OP_QMARK_NON_GREEDY))

        /// \n,\r,\t,\a ...
        public static let escControlChars = Syntax.Operators(rawValue: UInt64(ONIG_SYN_OP_ESC_CONTROL_CHARS))

        /// \cx
        public static let escCControl = Syntax.Operators(rawValue: UInt64(ONIG_SYN_OP_ESC_C_CONTROL))

        /// \OOO
        public static let escOctal3 = Syntax.Operators(rawValue: UInt64(ONIG_SYN_OP_ESC_OCTAL3))

        /// \xHH
        public static let escXHex2 = Syntax.Operators(rawValue: UInt64(ONIG_SYN_OP_ESC_X_HEX2))

        /// \x{7HHHHHHH}
        public static let escXBraceHex8 = Syntax.Operators(rawValue: UInt64(ONIG_SYN_OP_ESC_X_BRACE_HEX8))

        /// \o{1OOOOOOOOOO}
        public static let escOBraceOctal = Syntax.Operators(rawValue: UInt64(ONIG_SYN_OP_ESC_O_BRACE_OCTAL))

        /// \Q...\E
        public static let escCapitalQQuote = Syntax.Operators(rawValue: UInt64(ONIG_SYN_OP2_ESC_CAPITAL_Q_QUOTE) << 32)

        /// (?...)
        public static let qmarkGroupEffect = Syntax.Operators(rawValue: UInt64(ONIG_SYN_OP2_QMARK_GROUP_EFFECT) << 32)

        /// (?imsx),(?-imsx)
        public static let optionPerl = Syntax.Operators(rawValue: UInt64(ONIG_SYN_OP2_OPTION_PERL) << 32)

        /// (?imx), (?-imx)
        public static let optionRuby = Syntax.Operators(rawValue: UInt64(ONIG_SYN_OP2_OPTION_RUBY) << 32)

        /// ?+,*+,++
        public static let plusPossessiveRepeat = Syntax.Operators(
            rawValue: UInt64(ONIG_SYN_OP2_PLUS_POSSESSIVE_REPEAT) << 32
        )

        /// {n,m}+
        public static let plusPossessiveInterval = Syntax.Operators(
            rawValue: UInt64(ONIG_SYN_OP2_PLUS_POSSESSIVE_INTERVAL) << 32
        )

        /// [...&&..[..]..]
        public static let cclassSetOp = Syntax.Operators(rawValue: UInt64(ONIG_SYN_OP2_CCLASS_SET_OP) << 32)

        /// (?<name>...)
        public static let qmarkLtNamedGroup = Syntax.Operators(
            rawValue: UInt64(ONIG_SYN_OP2_QMARK_LT_NAMED_GROUP) << 32
        )

        /// \k<name>
        public static let escKNamedBackref = Syntax.Operators(rawValue: UInt64(ONIG_SYN_OP2_ESC_K_NAMED_BACKREF) << 32)

        /// \g<name>, \g<n>
        public static let escGSubexpCall = Syntax.Operators(rawValue: UInt64(ONIG_SYN_OP2_ESC_G_SUBEXP_CALL) << 32)

        /// (?@..),(?@<x>..)
        public static let atmarkCaptureHistory = Syntax.Operators(
            rawValue: UInt64(ONIG_SYN_OP2_ATMARK_CAPTURE_HISTORY) << 32
        )

        /// \C-x
        public static let escCapitalCBarControl = Syntax.Operators(
            rawValue: UInt64(ONIG_SYN_OP2_ESC_CAPITAL_C_BAR_CONTROL) << 32
        )

        /// \M-x
        public static let escCapitalMBarMeta = Syntax.Operators(
            rawValue: UInt64(ONIG_SYN_OP2_ESC_CAPITAL_M_BAR_META) << 32
        )

        /// \v as VTAB
        public static let escVVtab = Syntax.Operators(rawValue: UInt64(ONIG_SYN_OP2_ESC_V_VTAB) << 32)

        /// \uHHHH
        public static let escUHex4 = Syntax.Operators(rawValue: UInt64(ONIG_SYN_OP2_ESC_U_HEX4) << 32)

        /// \`, \'
        public static let escGnuBufAnchor = Syntax.Operators(rawValue: UInt64(ONIG_SYN_OP2_ESC_GNU_BUF_ANCHOR) << 32)

        /// \p{...}, \P{...}
        public static let escPBraceCharProperty = Syntax.Operators(
            rawValue: UInt64(ONIG_SYN_OP2_ESC_P_BRACE_CHAR_PROPERTY) << 32
        )

        /// \p{^..}, \P{^..}
        public static let escPBraceCircumflexNot = Syntax.Operators(
            rawValue: UInt64(ONIG_SYN_OP2_ESC_P_BRACE_CIRCUMFLEX_NOT) << 32
        )

        /// \h, \H
        public static let escHXdigit = Syntax.Operators(rawValue: UInt64(ONIG_SYN_OP2_ESC_H_XDIGIT) << 32)

        /// \
        public static let ineffectiveEscape = Syntax.Operators(rawValue: UInt64(ONIG_SYN_OP2_INEFFECTIVE_ESCAPE) << 32)

        /// (?(n)) (?(...)...|...)
        public static let qmarkLparenIfElse = Syntax.Operators(
            rawValue: UInt64(ONIG_SYN_OP2_QMARK_LPAREN_IF_ELSE) << 32
        )

        /// \K
        public static let escCapitalKKeep = Syntax.Operators(rawValue: UInt64(ONIG_SYN_OP2_ESC_CAPITAL_K_KEEP) << 32)

        /// \R \r\n else [\x0a-\x0d]
        public static let escCapitalRGeneralNewline = Syntax.Operators(
            rawValue: UInt64(ONIG_SYN_OP2_ESC_CAPITAL_R_GENERAL_NEWLINE) << 32
        )

        /// \N (?-m:.), \O (?m:.)
        public static let escCapitalNOSuperDot = Syntax.Operators(
            rawValue: UInt64(ONIG_SYN_OP2_ESC_CAPITAL_N_O_SUPER_DOT) << 32
        )

        /// (?~...)
        public static let qmarkTildeAbsentGroup = Syntax.Operators(
            rawValue: UInt64(ONIG_SYN_OP2_QMARK_TILDE_ABSENT_GROUP) << 32
        )

        /// obsoleted: use next
        public static let escXYGraphemeCluster = Syntax.Operators(
            rawValue: UInt64(ONIG_SYN_OP2_ESC_X_Y_GRAPHEME_CLUSTER) << 32
        )

        /// \X \y \Y
        public static let escXYTextSegment = Syntax.Operators(rawValue: UInt64(ONIG_SYN_OP2_ESC_X_Y_TEXT_SEGMENT) << 32)

        /// (?R), (?&name)...
        public static let qmarkPerlSubexpCall = Syntax.Operators(
            rawValue: UInt64(ONIG_SYN_OP2_QMARK_PERL_SUBEXP_CALL) << 32
        )

        /// (?{...}) (?{{...}})
        public static let qmarkBraceCalloutContents = Syntax.Operators(
            rawValue: UInt64(ONIG_SYN_OP2_QMARK_BRACE_CALLOUT_CONTENTS) << 32
        )

        /// (*name) (*name{a,..})
        public static let asteriskCalloutName = Syntax.Operators(
            rawValue: UInt64(ONIG_SYN_OP2_ASTERISK_CALLOUT_NAME) << 32
        )

        /// (?imxWDSPy)
        public static let optionOniguruma = Syntax.Operators(
            rawValue: UInt64(ONIG_SYN_OP2_OPTION_ONIGURUMA) << 32
        )

    //    /// (?P<name>...) (?P=name)
    //    public static let qmarkCapitalPName = Syntax.Operators(
    //      rawValue: UInt64(ONIG_SYN_OP2_QMARK_CAPITAL_P_NAME) << 32
    //    )

        public var onigSyntaxOp: OnigUInt {
            return OnigUInt(truncatingIfNeeded: self.rawValue)
        }

        public var onigSyntaxOp2: OnigUInt {
            return OnigUInt(truncatingIfNeeded: self.rawValue >> 32)
        }
    }

    /**
     Get or set the operators for this syntax.
     */
    public var operators: Syntax.Operators {
        get {
            return Syntax.Operators(onigSyntaxOp: onig_get_syntax_op(self.rawValue),
                                    onigSyntaxOp2: onig_get_syntax_op2(self.rawValue))
        }

        set {
            self.convertToOwnedIfNeeded()
            onig_set_syntax_op(self.rawValue, newValue.onigSyntaxOp)
            onig_set_syntax_op2(self.rawValue, newValue.onigSyntaxOp2)
        }
    }
}

/**
 Syntax behaviors
 */
extension Syntax {
    public struct Behaviors: OptionSet {
        public let rawValue: OnigUInt

        public init(rawValue: OnigUInt) {
            self.rawValue = rawValue
        }

        // syntax (behavior)

        /// ?, *, +, {n,m}
        public static let contextIndepRepeatOps = Syntax.Behaviors(rawValue: ONIG_SYN_CONTEXT_INDEP_REPEAT_OPS)

        /// error or ignore
        public static let contextInvalidRepeatOps = Syntax.Behaviors(rawValue: ONIG_SYN_CONTEXT_INVALID_REPEAT_OPS)

        /// ...)...
        public static let allowUnmatchedCloseSubexp = Syntax.Behaviors(rawValue: ONIG_SYN_ALLOW_UNMATCHED_CLOSE_SUBEXP)

        /// {???
        public static let allowInvalidInterval = Syntax.Behaviors(rawValue: ONIG_SYN_ALLOW_INVALID_INTERVAL)

        /// {,n} => {0,n}
        public static let allowIntervalLowAbbrev = Syntax.Behaviors(rawValue: ONIG_SYN_ALLOW_INTERVAL_LOW_ABBREV)

        /// /(\1)/,/\1()/ ..
        public static let strictCheckBackref = Syntax.Behaviors(rawValue: ONIG_SYN_STRICT_CHECK_BACKREF)

        /// (?<=a|bc)
        public static let differentLenAltLookBehind = Syntax.Behaviors(rawValue: ONIG_SYN_DIFFERENT_LEN_ALT_LOOK_BEHIND)

        /// see doc/RE
        public static let captureOnlyNamedGroup = Syntax.Behaviors(rawValue: ONIG_SYN_CAPTURE_ONLY_NAMED_GROUP)

        /// (?<x>)(?<x>)
        public static let allowMultiplexDefinitionName = Syntax.Behaviors(
            rawValue: ONIG_SYN_ALLOW_MULTIPLEX_DEFINITION_NAME
        )

        /// a{n}?=(?:a{n})?
        public static let fixedIntervalIsGreedyOnly = Syntax.Behaviors(rawValue: ONIG_SYN_FIXED_INTERVAL_IS_GREEDY_ONLY)

        /// ..(?i)...|...
        public static let isolatedOptionContinueBranch = Syntax.Behaviors(
            rawValue: ONIG_SYN_ISOLATED_OPTION_CONTINUE_BRANCH
        )

        /// (?<=a+|..)
        public static let variableLenLookBehind = Syntax.Behaviors(rawValue: ONIG_SYN_VARIABLE_LEN_LOOK_BEHIND)

        /// \UHHHHHHHH
    //    public static let python = Syntax.Behaviors(rawValue: ONIG_SYN_PYTHON)

        // syntax (behavior) in char class [...]

        /// [^...]
        public static let notNewlineInNegativeCc = Syntax.Behaviors(rawValue: ONIG_SYN_NOT_NEWLINE_IN_NEGATIVE_CC)

        /// [..\w..] etc..
        public static let backslashEscapeInCc = Syntax.Behaviors(rawValue: ONIG_SYN_BACKSLASH_ESCAPE_IN_CC)

        public static let allowEmptyRangeInCc = Syntax.Behaviors(rawValue: ONIG_SYN_ALLOW_EMPTY_RANGE_IN_CC)

        /// [0-9-a]=[0-9\-a]
        public static let allowDoubleRangeOpInCc = Syntax.Behaviors(rawValue: ONIG_SYN_ALLOW_DOUBLE_RANGE_OP_IN_CC)

        public static let allowInvalidCodeEndOfRangeInCc = Syntax.Behaviors(
            rawValue: ONIG_SYN_ALLOW_INVALID_CODE_END_OF_RANGE_IN_CC
        )

        // syntax (behavior) warning

        /// [,-,]
        public static let warnCcOpNotEscaped = Syntax.Behaviors(rawValue: ONIG_SYN_WARN_CC_OP_NOT_ESCAPED)

        /// (?:a*)+
        public static let warnRedundantNestedRepeat = Syntax.Behaviors(rawValue: ONIG_SYN_WARN_REDUNDANT_NESTED_REPEAT)
    }

    /**
     Get or set the syntax behaviours
     */
    public var behaviors: Syntax.Behaviors {
        get {
            return Syntax.Behaviors(rawValue: onig_get_syntax_behavior(self.rawValue))
        }

        set {
            self.convertToOwnedIfNeeded()
            onig_set_syntax_behavior(self.rawValue, newValue.rawValue)
        }
    }
}

/**
 Syntax metachars
 */
extension Syntax {
    /**
     Meta character specifiers
     */
    public enum MetaCharType: CustomStringConvertible {
        /// The escape character
        case escape
        /// The any character (.)
        case anyChar
        /// The any number of repeats character (*)
        case anyTime
        /// The optinoal chracter (?)
        case zeroOrOneTime
        /// The at least once character (+)
        case oneOrMoreTime
        /// The glob character (.*)
        case anyCharAnyTime

        public var description: String {
            switch self {
            case .escape:
                return "escape"
            case .anyChar:
                return "anyChar"
            case .anyTime:
                return "anyTime"
            case .zeroOrOneTime:
                return "zeroOrOneTime"
            case .oneOrMoreTime:
                return "oneOrMoreTime"
            case .anyCharAnyTime:
                return "anyCharAnyTime"
            }
        }
    }

    public enum MetaChar: Equatable, CustomStringConvertible {
        /// The meta character is not enabled
        case ineffective
        /// The meta character is set to the chosen `OnigCodePoint`
        case codePoint(OnigCodePoint)

        internal init(with onigCodePoint: OnigCodePoint) {
            if onigCodePoint == ONIG_INEFFECTIVE_META_CHAR {
                self = .ineffective
            } else {
                self = .codePoint(onigCodePoint)
            }
        }

        /**
         Init a `MetaChar` with a string.
         - Note: if the string is empty or its `utf8` view has more than `MemoryLayout<OnigCodePoint>.size`
         bytes (*4* bytes), the result will be `.Ineffective`.
         */
        public init(from str: String) {
            let codePointByteCount = MemoryLayout<OnigCodePoint>.size
            let bytes = [UInt8](str.utf8)
            if bytes.isEmpty || bytes.count > codePointByteCount {
                self = .ineffective
            } else {
                var codePoint: OnigCodePoint = 0
                for number in 0..<min(bytes.count, codePointByteCount) {
                    codePoint = (codePoint << 8) | OnigCodePoint(bytes[number])
                }
                self = .codePoint(codePoint)
            }
        }

        internal var onigCodePoint: OnigCodePoint {
            switch self {
            case .ineffective:
                return OnigCodePoint(ONIG_INEFFECTIVE_META_CHAR)
            case .codePoint(let codePoint):
                return codePoint
            }
        }

        public var description: String {
            switch self {
            case .ineffective:
                return ""
            case .codePoint(var codePoint):
                return withUnsafeBytes(of: &codePoint) {
                    var bytes = Array($0.bindMemory(to: UInt8.self))
                    bytes.append(0)
                    return String(cString: bytes)
                }
            }
        }
    }

    public struct MetaCharTable {
        internal typealias OnigMetaCharTablePtr = UnsafeMutablePointer<OnigMetaCharTableType>
        internal var rawValue: OnigMetaCharTablePtr!

        internal init(rawValue: OnigMetaCharTablePtr!) {
            self.rawValue = rawValue
        }

        subscript(index: MetaCharType) -> MetaChar {
            get {
                switch index {
                case .escape:
                    return MetaChar(with: self.rawValue.pointee.esc)
                case .anyChar:
                    return MetaChar(with: self.rawValue.pointee.anychar)
                case .anyTime:
                    return MetaChar(with: self.rawValue.pointee.anytime)
                case .zeroOrOneTime:
                    return MetaChar(with: self.rawValue.pointee.zero_or_one_time)
                case .oneOrMoreTime:
                    return MetaChar(with: self.rawValue.pointee.one_or_more_time)
                case .anyCharAnyTime:
                    return MetaChar(with: self.rawValue.pointee.anychar_anytime)
                }
            }

            set {
                switch index {
                case .escape:
                    self.rawValue.pointee.esc = newValue.onigCodePoint
                case .anyChar:
                    self.rawValue.pointee.anychar = newValue.onigCodePoint
                case .anyTime:
                    self.rawValue.pointee.anytime = newValue.onigCodePoint
                case .zeroOrOneTime:
                    self.rawValue.pointee.zero_or_one_time = newValue.onigCodePoint
                case .oneOrMoreTime:
                    self.rawValue.pointee.one_or_more_time = newValue.onigCodePoint
                case .anyCharAnyTime:
                    self.rawValue.pointee.anychar_anytime = newValue.onigCodePoint
                }
            }
        }
    }

    /**
     Meta char table of the syntax.
     */
    public var metaCharTable: MetaCharTable {
        get {
            return MetaCharTable(rawValue: &self.rawValue.pointee.meta_char_table)
        }

        set {
            if newValue.rawValue == nil {
                return
            }

            self.convertToOwnedIfNeeded()

            if newValue.rawValue == &self.rawValue.pointee.meta_char_table {
                // same table
                return
            }

            self.rawValue.pointee.meta_char_table = newValue.rawValue.pointee
        }
    }
} // swiftlint:disable:this file_length
