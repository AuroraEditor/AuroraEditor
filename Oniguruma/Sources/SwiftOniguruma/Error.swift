//
//  Error.swift
//  
//
//  Created by Gavin Mao on 3/27/21.
//

import oniguruma

public enum OnigError: Error, Equatable {
    /* internal error */
    case memory
    case typeBug
    case parserBug
    case stackBug
    case undefinedBytecode
    case unexpectedBytecode
    case matchStackLimitOver
    case parseDepthLimitOver
    case retryLimitInMatchOver
    case retryLimitInSearchOver
    case subexpCallLimitInSearchOver
    case defaultEncodingIsNotSetted
    case specifiedEncodingCantConvertToWideChar
    case failToInitialize

    /* general error */
    case invalidArgument

    /* syntax error */
    case endPatternAtLeftBrace
    case endPatternAtLeftBracket
    case emptyCharClass
    case prematureEndOfCharClass
    case endPatternAtEscape
    case endPatternAtMeta
    case endPatternAtControl
    case metaCodeSyntax
    case controlCodeSyntax
    case charClassValueAtEndOfRange
    case charClassValueAtStartOfRange
    case unmatchedRangeSpecifierInCharClass
    case targetOfRepeatOperatorNotSpecified
    case targetOfRepeatOperatorInvalid
    case nestedRepeatOperator
    case unmatchedCloseParenthesis
    case endPatternWithUnmatchedParenthesis
    case endPatternInGroup
    case undefinedGroupOption
    case invalidPosixBracketType
    case invalidLookBehindPattern
    case invalidRepeatRangePattern

    /* values error (syntax error) */
    case tooBigNumber
    case tooBigNumberForRepeatRange
    case upperSmallerThanLowerInRepeatRange
    case emptyRangeInCharClass
    case mismatchCodeLengthInClassRange
    case tooManyMultiByteRanges
    case tooShortMultiByteString
    case tooBigBackrefNumber
    case invalidBackref
    case numberedBackrefOrCallNotAllowed
    case tooManyCaptures
    case tooLongWideCharValue
    case emptyGroupName
    case invalidGroupName(String)
    case invalidCharInGroupName(String)
    case undefinedNameReference(String)
    case undefinedGroupReference(String)
    case multiplexDefinedName(String)
    case multiplexDefinitionNameCall(String)
    case neverEndingRecursion
    case groupNumberOverForCaptureHistory
    case invalidCharPropertyName(String)
    case invalidIfElseSyntax
    case invalidAbsentGroupPattern
    case invalidAbsentGroupGeneratorPattern
    case invalidCalloutPattern
    case invalidCalloutName
    case undefinedCalloutName
    case invalidCalloutBody
    case invalidCalloutTagName
    case invalidCalloutArg
    case invalidCodePointValue
    case invalidWideCharValue
    case tooBigWideCharValue
    case notSupportedEncodingCombination
    case invalidCombinationOfOptions
    case tooManyUserDefinedObjects
    case tooLongPropertyName
    case libraryIsNotInitialized
}

extension OnigError {
    // swiftlint:disable:next function_body_length
    public init(onigErrorCode: OnigInt, onigErrorInfo: OnigErrorInfo? = nil) {
        switch onigErrorCode {
        /* internal error */
        case ONIGERR_MEMORY:
            self = .memory
        case ONIGERR_TYPE_BUG:
            self = .typeBug
        case ONIGERR_PARSER_BUG:
            self = .parserBug
        case ONIGERR_STACK_BUG:
            self = .stackBug
        case ONIGERR_UNDEFINED_BYTECODE:
            self = .undefinedBytecode
        case ONIGERR_UNEXPECTED_BYTECODE:
            self = .unexpectedBytecode
        case ONIGERR_MATCH_STACK_LIMIT_OVER:
            self = .matchStackLimitOver
        case ONIGERR_PARSE_DEPTH_LIMIT_OVER:
            self = .parseDepthLimitOver
        case ONIGERR_RETRY_LIMIT_IN_MATCH_OVER:
            self = .retryLimitInMatchOver
        case ONIGERR_RETRY_LIMIT_IN_SEARCH_OVER:
            self = .retryLimitInSearchOver
        case ONIGERR_SUBEXP_CALL_LIMIT_IN_SEARCH_OVER:
            self = .subexpCallLimitInSearchOver
        case ONIGERR_DEFAULT_ENCODING_IS_NOT_SETTED:
            self = .defaultEncodingIsNotSetted
        case ONIGERR_SPECIFIED_ENCODING_CANT_CONVERT_TO_WIDE_CHAR:
            self = .specifiedEncodingCantConvertToWideChar
        case ONIGERR_FAIL_TO_INITIALIZE:
            self = .failToInitialize

        /* general error */
        case ONIGERR_INVALID_ARGUMENT:
            self = .invalidArgument

        /* syntax error */
        case ONIGERR_END_PATTERN_AT_LEFT_BRACE:
            self = .endPatternAtLeftBrace
        case ONIGERR_END_PATTERN_AT_LEFT_BRACKET:
            self = .endPatternAtLeftBracket
        case ONIGERR_EMPTY_CHAR_CLASS:
            self = .emptyCharClass
        case ONIGERR_PREMATURE_END_OF_CHAR_CLASS:
            self = .prematureEndOfCharClass
        case ONIGERR_END_PATTERN_AT_ESCAPE:
            self = .endPatternAtEscape
        case ONIGERR_END_PATTERN_AT_META:
            self = .endPatternAtMeta
        case ONIGERR_END_PATTERN_AT_CONTROL:
            self = .endPatternAtControl
        case ONIGERR_META_CODE_SYNTAX:
            self = .metaCodeSyntax
        case ONIGERR_CONTROL_CODE_SYNTAX:
            self = .controlCodeSyntax
        case ONIGERR_CHAR_CLASS_VALUE_AT_END_OF_RANGE:
            self = .charClassValueAtEndOfRange
        case ONIGERR_CHAR_CLASS_VALUE_AT_START_OF_RANGE:
            self = .charClassValueAtStartOfRange
        case ONIGERR_UNMATCHED_RANGE_SPECIFIER_IN_CHAR_CLASS:
            self = .unmatchedRangeSpecifierInCharClass
        case ONIGERR_TARGET_OF_REPEAT_OPERATOR_NOT_SPECIFIED:
            self = .targetOfRepeatOperatorNotSpecified
        case ONIGERR_TARGET_OF_REPEAT_OPERATOR_INVALID:
            self = .targetOfRepeatOperatorInvalid
        case ONIGERR_NESTED_REPEAT_OPERATOR:
            self = .nestedRepeatOperator
        case ONIGERR_UNMATCHED_CLOSE_PARENTHESIS:
            self = .unmatchedCloseParenthesis
        case ONIGERR_END_PATTERN_WITH_UNMATCHED_PARENTHESIS:
            self = .endPatternWithUnmatchedParenthesis
        case ONIGERR_END_PATTERN_IN_GROUP:
            self = .endPatternInGroup
        case ONIGERR_UNDEFINED_GROUP_OPTION:
            self = .undefinedGroupOption
        case ONIGERR_INVALID_POSIX_BRACKET_TYPE:
            self = .invalidPosixBracketType
        case ONIGERR_INVALID_LOOK_BEHIND_PATTERN:
            self = .invalidLookBehindPattern
        case ONIGERR_INVALID_REPEAT_RANGE_PATTERN:
            self = .invalidRepeatRangePattern

        /* values error (syntax error) */
        case ONIGERR_TOO_BIG_NUMBER:
            self = .tooBigNumber
        case ONIGERR_TOO_BIG_NUMBER_FOR_REPEAT_RANGE:
            self = .tooBigNumberForRepeatRange
        case ONIGERR_UPPER_SMALLER_THAN_LOWER_IN_REPEAT_RANGE:
            self = .upperSmallerThanLowerInRepeatRange
        case ONIGERR_EMPTY_RANGE_IN_CHAR_CLASS:
            self = .emptyRangeInCharClass
        case ONIGERR_MISMATCH_CODE_LENGTH_IN_CLASS_RANGE:
            self = .mismatchCodeLengthInClassRange
        case ONIGERR_TOO_MANY_MULTI_BYTE_RANGES:
            self = .tooManyMultiByteRanges
        case ONIGERR_TOO_SHORT_MULTI_BYTE_STRING:
            self = .tooShortMultiByteString
        case ONIGERR_TOO_BIG_BACKREF_NUMBER:
            self = .tooBigBackrefNumber
        case ONIGERR_INVALID_BACKREF:
            self = .invalidBackref
        case ONIGERR_NUMBERED_BACKREF_OR_CALL_NOT_ALLOWED:
            self = .numberedBackrefOrCallNotAllowed
        case ONIGERR_TOO_MANY_CAPTURES:
            self = .tooManyCaptures
        case ONIGERR_TOO_LONG_WIDE_CHAR_VALUE:
            self = .tooLongWideCharValue
        case ONIGERR_EMPTY_GROUP_NAME:
            self = .emptyGroupName
        case ONIGERR_INVALID_GROUP_NAME:
            self = .invalidGroupName(onigErrorInfo?.description ?? "")
        case ONIGERR_INVALID_CHAR_IN_GROUP_NAME:
            self = .invalidCharInGroupName(onigErrorInfo?.description ?? "")
        case ONIGERR_UNDEFINED_NAME_REFERENCE:
            self = .undefinedNameReference(onigErrorInfo?.description ?? "")
        case ONIGERR_UNDEFINED_GROUP_REFERENCE:
            self = .undefinedGroupReference(onigErrorInfo?.description ?? "")
        case ONIGERR_MULTIPLEX_DEFINED_NAME:
            self = .multiplexDefinedName(onigErrorInfo?.description ?? "")
        case ONIGERR_MULTIPLEX_DEFINITION_NAME_CALL:
            self = .multiplexDefinitionNameCall(onigErrorInfo?.description ?? "")
        case ONIGERR_NEVER_ENDING_RECURSION:
            self = .neverEndingRecursion
        case ONIGERR_GROUP_NUMBER_OVER_FOR_CAPTURE_HISTORY:
            self = .groupNumberOverForCaptureHistory
        case ONIGERR_INVALID_CHAR_PROPERTY_NAME:
            self = .invalidCharPropertyName(onigErrorInfo?.description ?? "")
        case ONIGERR_INVALID_IF_ELSE_SYNTAX:
            self = .invalidIfElseSyntax
        case ONIGERR_INVALID_ABSENT_GROUP_PATTERN:
            self = .invalidAbsentGroupPattern
        case ONIGERR_INVALID_ABSENT_GROUP_GENERATOR_PATTERN:
            self = .invalidAbsentGroupGeneratorPattern
        case ONIGERR_INVALID_CALLOUT_PATTERN:
            self = .invalidCalloutPattern
        case ONIGERR_INVALID_CALLOUT_NAME:
            self = .invalidCalloutName
        case ONIGERR_UNDEFINED_CALLOUT_NAME:
            self = .undefinedCalloutName
        case ONIGERR_INVALID_CALLOUT_BODY:
            self = .invalidCalloutBody
        case ONIGERR_INVALID_CALLOUT_TAG_NAME:
            self = .invalidCalloutTagName
        case ONIGERR_INVALID_CALLOUT_ARG:
            self = .invalidCalloutArg
        case ONIGERR_INVALID_CODE_POINT_VALUE:
            self = .invalidCodePointValue
        case ONIGERR_INVALID_WIDE_CHAR_VALUE:
            self = .invalidWideCharValue
        case ONIGERR_TOO_BIG_WIDE_CHAR_VALUE:
            self = .tooBigWideCharValue
        case ONIGERR_NOT_SUPPORTED_ENCODING_COMBINATION:
            self = .notSupportedEncodingCombination
        case ONIGERR_INVALID_COMBINATION_OF_OPTIONS:
            self = .invalidCombinationOfOptions
        case ONIGERR_TOO_MANY_USER_DEFINED_OBJECTS:
            self = .tooManyUserDefinedObjects
        case ONIGERR_TOO_LONG_PROPERTY_NAME:
            self = .tooLongPropertyName
        case ONIGERR_LIBRARY_IS_NOT_INITIALIZED:
            self = .libraryIsNotInitialized
        default:
            fatalError("Unexpected onig error code: \(onigErrorCode)")
        }
    }

    public var onigErrorCode: OnigInt {
        switch self {
        /* internal error */
        case .memory:
            return ONIGERR_MEMORY
        case .typeBug:
            return ONIGERR_TYPE_BUG
        case .parserBug:
            return ONIGERR_PARSER_BUG
        case .stackBug:
            return ONIGERR_STACK_BUG
        case .undefinedBytecode:
            return ONIGERR_UNDEFINED_BYTECODE
        case .unexpectedBytecode:
            return ONIGERR_UNEXPECTED_BYTECODE
        case .matchStackLimitOver:
            return ONIGERR_MATCH_STACK_LIMIT_OVER
        case .parseDepthLimitOver:
            return ONIGERR_PARSE_DEPTH_LIMIT_OVER
        case .retryLimitInMatchOver:
            return ONIGERR_RETRY_LIMIT_IN_MATCH_OVER
        case .retryLimitInSearchOver:
            return ONIGERR_RETRY_LIMIT_IN_SEARCH_OVER
        case .subexpCallLimitInSearchOver:
            return ONIGERR_SUBEXP_CALL_LIMIT_IN_SEARCH_OVER
        case .defaultEncodingIsNotSetted:
            return ONIGERR_DEFAULT_ENCODING_IS_NOT_SETTED
        case .specifiedEncodingCantConvertToWideChar:
            return ONIGERR_SPECIFIED_ENCODING_CANT_CONVERT_TO_WIDE_CHAR
        case .failToInitialize:
            return ONIGERR_FAIL_TO_INITIALIZE

        /* general error */
        case .invalidArgument:
            return ONIGERR_INVALID_ARGUMENT

        /* syntax error */
        case .endPatternAtLeftBrace:
            return ONIGERR_END_PATTERN_AT_LEFT_BRACE
        case .endPatternAtLeftBracket:
            return ONIGERR_END_PATTERN_AT_LEFT_BRACKET
        case .emptyCharClass:
            return ONIGERR_EMPTY_CHAR_CLASS
        case .prematureEndOfCharClass:
            return ONIGERR_PREMATURE_END_OF_CHAR_CLASS
        case .endPatternAtEscape:
            return ONIGERR_END_PATTERN_AT_ESCAPE
        case .endPatternAtMeta:
            return ONIGERR_END_PATTERN_AT_META
        case .endPatternAtControl:
            return ONIGERR_END_PATTERN_AT_CONTROL
        case .metaCodeSyntax:
            return ONIGERR_META_CODE_SYNTAX
        case .controlCodeSyntax:
            return ONIGERR_CONTROL_CODE_SYNTAX
        case .charClassValueAtEndOfRange:
            return ONIGERR_CHAR_CLASS_VALUE_AT_END_OF_RANGE
        case .charClassValueAtStartOfRange:
            return ONIGERR_CHAR_CLASS_VALUE_AT_START_OF_RANGE
        case .unmatchedRangeSpecifierInCharClass:
            return ONIGERR_UNMATCHED_RANGE_SPECIFIER_IN_CHAR_CLASS
        case .targetOfRepeatOperatorNotSpecified:
            return ONIGERR_TARGET_OF_REPEAT_OPERATOR_NOT_SPECIFIED
        case .targetOfRepeatOperatorInvalid:
            return ONIGERR_TARGET_OF_REPEAT_OPERATOR_INVALID
        case .nestedRepeatOperator:
            return ONIGERR_NESTED_REPEAT_OPERATOR
        case .unmatchedCloseParenthesis:
            return ONIGERR_UNMATCHED_CLOSE_PARENTHESIS
        case .endPatternWithUnmatchedParenthesis:
            return ONIGERR_END_PATTERN_WITH_UNMATCHED_PARENTHESIS
        case .endPatternInGroup:
            return ONIGERR_END_PATTERN_IN_GROUP
        case .undefinedGroupOption:
            return ONIGERR_UNDEFINED_GROUP_OPTION
        case .invalidPosixBracketType:
            return ONIGERR_INVALID_POSIX_BRACKET_TYPE
        case .invalidLookBehindPattern:
            return ONIGERR_INVALID_LOOK_BEHIND_PATTERN
        case .invalidRepeatRangePattern:
            return ONIGERR_INVALID_REPEAT_RANGE_PATTERN

        /* values error (syntax error) */
        case .tooBigNumber:
            return ONIGERR_TOO_BIG_NUMBER
        case .tooBigNumberForRepeatRange:
            return ONIGERR_TOO_BIG_NUMBER_FOR_REPEAT_RANGE
        case .upperSmallerThanLowerInRepeatRange:
            return ONIGERR_UPPER_SMALLER_THAN_LOWER_IN_REPEAT_RANGE
        case .emptyRangeInCharClass:
            return ONIGERR_EMPTY_RANGE_IN_CHAR_CLASS
        case .mismatchCodeLengthInClassRange:
            return ONIGERR_MISMATCH_CODE_LENGTH_IN_CLASS_RANGE
        case .tooManyMultiByteRanges:
            return ONIGERR_TOO_MANY_MULTI_BYTE_RANGES
        case .tooShortMultiByteString:
            return ONIGERR_TOO_SHORT_MULTI_BYTE_STRING
        case .tooBigBackrefNumber:
            return ONIGERR_TOO_BIG_BACKREF_NUMBER
        case .invalidBackref:
            return ONIGERR_INVALID_BACKREF
        case .numberedBackrefOrCallNotAllowed:
            return ONIGERR_NUMBERED_BACKREF_OR_CALL_NOT_ALLOWED
        case .tooManyCaptures:
            return ONIGERR_TOO_MANY_CAPTURES
        case .tooLongWideCharValue:
            return ONIGERR_TOO_LONG_WIDE_CHAR_VALUE
        case .emptyGroupName:
            return ONIGERR_EMPTY_GROUP_NAME
        case .invalidGroupName:
            return ONIGERR_INVALID_GROUP_NAME
        case .invalidCharInGroupName:
            return ONIGERR_INVALID_CHAR_IN_GROUP_NAME
        case .undefinedNameReference:
            return ONIGERR_UNDEFINED_NAME_REFERENCE
        case .undefinedGroupReference:
            return ONIGERR_UNDEFINED_GROUP_REFERENCE
        case .multiplexDefinedName:
            return ONIGERR_MULTIPLEX_DEFINED_NAME
        case .multiplexDefinitionNameCall:
            return ONIGERR_MULTIPLEX_DEFINITION_NAME_CALL
        case .neverEndingRecursion:
            return ONIGERR_NEVER_ENDING_RECURSION
        case .groupNumberOverForCaptureHistory:
            return ONIGERR_GROUP_NUMBER_OVER_FOR_CAPTURE_HISTORY
        case .invalidCharPropertyName:
            return ONIGERR_INVALID_CHAR_PROPERTY_NAME
        case .invalidIfElseSyntax:
            return ONIGERR_INVALID_IF_ELSE_SYNTAX
        case .invalidAbsentGroupPattern:
            return ONIGERR_INVALID_ABSENT_GROUP_PATTERN
        case .invalidAbsentGroupGeneratorPattern:
            return ONIGERR_INVALID_ABSENT_GROUP_GENERATOR_PATTERN
        case .invalidCalloutPattern:
            return ONIGERR_INVALID_CALLOUT_PATTERN
        case .invalidCalloutName:
            return ONIGERR_INVALID_CALLOUT_NAME
        case .undefinedCalloutName:
            return ONIGERR_UNDEFINED_CALLOUT_NAME
        case .invalidCalloutBody:
            return ONIGERR_INVALID_CALLOUT_BODY
        case .invalidCalloutTagName:
            return ONIGERR_INVALID_CALLOUT_TAG_NAME
        case .invalidCalloutArg:
            return ONIGERR_INVALID_CALLOUT_ARG
        case .invalidCodePointValue:
            return ONIGERR_INVALID_CODE_POINT_VALUE
        case .invalidWideCharValue:
            return ONIGERR_INVALID_WIDE_CHAR_VALUE
        case .tooBigWideCharValue:
            return ONIGERR_TOO_BIG_WIDE_CHAR_VALUE
        case .notSupportedEncodingCombination:
            return ONIGERR_NOT_SUPPORTED_ENCODING_COMBINATION
        case .invalidCombinationOfOptions:
            return ONIGERR_INVALID_COMBINATION_OF_OPTIONS
        case .tooManyUserDefinedObjects:
            return ONIGERR_TOO_MANY_USER_DEFINED_OBJECTS
        case .tooLongPropertyName:
            return ONIGERR_TOO_LONG_PROPERTY_NAME
        case .libraryIsNotInitialized:
            return ONIGERR_LIBRARY_IS_NOT_INITIALIZED
        }
    }
}

extension OnigErrorInfo: CustomStringConvertible {
    /**
     Get the content of this `OnigErrorInfo`.
     - Returns: A string if the encoding is supposted by swfit string. Otherwise an array of raw bytes.
     */
    public var description: String {
        if self.par == nil || self.par_end == nil {
            return ""
        }

        let encoding = Encoding(rawValue: self.enc)
        let buf = UnsafeBufferPointer(start: self.par, count: self.par.distance(to: self.par_end))
        return String(bytes: buf, encoding: encoding.stringEncoding) ?? Array(buf).description
    }
} // swiftlint:disable:this file_length
