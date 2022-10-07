//
//  RegexSet.swift
//  
//
//  Created by Gavin Mao on 4/2/21.
//

import Oniguruma

/**
 A wrapper of oniguruma `OnigRegSet` which represents the a set of regular expressions.
 
 In `SwiftOnig`, `RegexSet` is supposed to be immutable, thoses APIs in oniguruma are wrapped:
 - `onig_regset_new`: wrapped in `init`.
 - `onig_regset_free`: wrapped in `deinit`.
 - `onig_regset_number_of_regex`, wrapped in `endIndex` of `RandomAccessCollection`.
 - `onig_regset_get_regex`: wrapped in `subscription(position:)`.
 - `onig_regset_get_region`: Used in `search(*)`.
 - `onig_regset_search`, `onig_regset_search_with_param` : Wrapped in `search(*)`.

 Those APIs are not wrapped.
 - `onig_regset_add`: not exposed.
 - `onig_regset_replace`: not exposed.
 */
public final class RegexSet {
    internal typealias OnigRegSet = OpaquePointer
    internal private(set) var rawValue: OnigRegSet!

    /// Cached `Regex` objects
    private let regexes: [Regex]

    // MARK: init & deinit

    /**
     Create a `RegexSet` with a sequence of regular expressions.
     
     The encoding of each regular expressions should be the same.
     - Parameter regexes: A sequence of regular expressions.
     - Throws: `OnigError`
     */
    public init<S>(regexes: S) throws where S: Sequence, S.Element == Regex {
        self.regexes = [Regex](regexes)

        onig_regset_new(&self.rawValue, 0, nil)
        for reg in regexes {
            do {
                try callOnigFunction {
                    onig_regset_add(self.rawValue, reg.rawValue)
                }
            } catch {
                self._cleanUp()
                throw error
            }
        }
    }

    /**
     Create a `RegexSet` with a sequence of string patterns.

     As swift string uses UTF-8 as internal storage from swift 5,
     UTF-8 encoding (`Encoding.utf8`) will be used for swift string pattern.
     - Parameters:
         - patterns: Patterns used to create these regular expressions.
         - option: Options used to create these regular expressions.
         - syntax: Syntax used to create these regular expressions.
     - Throws: `OnigError`
     */
    public init<S, P>(patterns: S,
                      options: Regex.Options = .none,
                      syntax: Syntax = .default
    ) throws where S: Sequence, S.Element == P, P: StringProtocol {
        self.regexes = try patterns.map { try Regex(pattern: $0,
                                                    options: options,
                                                    syntax: syntax) }
        onig_regset_new(&self.rawValue, 0, nil)
        for reg in self.regexes {
            do {
                try callOnigFunction {
                    onig_regset_add(self.rawValue, reg.rawValue)
                }
            } catch {
                self._cleanUp()
                throw error
            }
        }
    }

    /**
     Create a `RegexSet` with a sequence of patterns.

     - Parameters:
         - patterns: Patterns used to create these regular expressions.
         - encoding: Encoding used to create these regular expressions.
         - option: Options used to create these regular expressions.
         - syntax: Syntax used to create these regular expressions.
     - Throws: `OnigError`
     */
    public init<S, P>(patternsBytes: S,
                      encoding: Encoding,
                      options: Regex.Options = .none,
                      syntax: Syntax = .default
    ) throws where S: Sequence, S.Element == P, P: Sequence, P.Element == UInt8 {
        self.regexes = try patternsBytes.map { try Regex(patternBytes: $0,
                                                         encoding: encoding,
                                                         options: options,
                                                         syntax: syntax) }
        onig_regset_new(&self.rawValue, 0, nil)
        for reg in self.regexes {
            do {
                try callOnigFunction {
                    onig_regset_add(self.rawValue, reg.rawValue)
                }
            } catch {
                self._cleanUp()
                throw error
            }
        }
    }

    deinit {
        self._cleanUp()
    }

    // MARK: Search API

    /**
     Search a string and return the first matching region.

     If `str` conforms to `StringProtocol`,
     will search against the UTF-8 bytes of the string.
     Do not pass invalid bytes in the regular expression encoding.

     - Parameters:
        - str: The target string to search against.
        - lead: Outer loop element, both `.positionLead` and `.regexLead` gurantee to
     return the *true* left most matched position, but in most cases `.positionLead` seems to
     be faster. `.priorityToRegexOrder` gurantee the returned regex index is the index of the
     *first* regular expression that coult match.
        - option: The regular expression search options.
        - matchParams: Match patameters, count **must** be equal to count of regular expressions.
     - Returns: A tuple of matched regular expression index and matching region. Or `nil` if no match is found.
     - Throws: `OnigError`
     */
    public func firstMatch<S>(in str: S,
                              lead: Lead = .positionLead,
                              options: Regex.SearchOptions = .none,
                              matchParams: [MatchParam]? = nil
    ) throws -> (regexIndex: Int, region: Region)? where S: OnigurumaString {
        try self.firstMatch(in: str,
                            of: 0...,
                            lead: lead,
                            options: options,
                            matchParams: matchParams)
    }

    /**
     Search a range of string and return the first matching region.

     If `str` conforms to `StringProtocol`,
     will search against the UTF-8 bytes of the string. Do not pass invalid bytes in the regular expression encoding.

     - Parameters:
        - str: The target string to search against.
        - range: The range of bytes to search against. It will be clamped to the range of the whole string first.
        - lead: Outer loop element, both `.positionLead` and `.regexLead` gurantee to
     return the *true* left most matched position, but in most cases `.positionLead`
     seems to be faster. `.priorityToRegexOrder` gurantee the returned regex index
     is the index of the *first* regular expression that coult match.
        - option: The regular expression search options.
        - matchParams: Match patameters, count **must** be equal to count of regular expressions.
     - Returns: A tuple of matched regular expression index and matching region. Or `nil` if no match is found.
     - Throws: `OnigError`
     */
    public func firstMatch<S, R>(in str: S,
                                 of range: R,
                                 lead: Lead = .positionLead,
                                 options: Regex.SearchOptions = .none,
                                 matchParams: [MatchParam]? = nil
    ) throws -> (regexIndex: Int, region: Region)? where S: OnigurumaString, R: RangeExpression, R.Bound == Int {
        let result = try str.withOnigurumaString { (start, count) throws -> OnigInt in
            var bytesIndex: OnigInt = 0
            let range = range.relative(to: 0..<count).clamped(to: 0..<count)
            if let matchParams = matchParams {
                let mps = UnsafeMutableBufferPointer<OpaquePointer?>.allocate(capacity: matchParams.count)
                _ = mps.initialize(from: matchParams.map { $0.rawValue })
                defer {
                    mps.deallocate()
                }

                return onig_regset_search_with_param(self.rawValue,
                                                     start,
                                                     start.advanced(by: count),
                                                     start.advanced(by: range.lowerBound),
                                                     start.advanced(by: range.upperBound),
                                                     lead.onigRegSetLead,
                                                     options.rawValue,
                                                     mps.baseAddress,
                                                     &bytesIndex)
            } else {
                return onig_regset_search(self.rawValue,
                                          start,
                                          start.advanced(by: count),
                                          start.advanced(by: range.lowerBound),
                                          start.advanced(by: range.upperBound),
                                          lead.onigRegSetLead,
                                          options.rawValue,
                                          &bytesIndex)
            }
        }

        if result == ONIG_MISMATCH {
            return nil
        } else {
            let onigRegion = onig_regset_get_region(self.rawValue, result)
            return(regexIndex: Int(result),
                   region: try Region(copying: onigRegion,
                                      regex: self.regexes[Int(result)],
                                      str: str))
        }
    }

    /**
     Clean up oniruguma regset object and cached `Regex`.
     */
    private func _cleanUp() {
        if self.rawValue != nil {
            for number in (0..<self.count).reversed() {
                // mark all regex object in the regset to be nil
                onig_regset_replace(self.rawValue, OnigInt(number), nil)
            }

            onig_regset_free(self.rawValue)
            self.rawValue = nil
        }
    }

    /**
     Out loop element when performing search.
     */
    public enum Lead {
        /**
         When performing the search, the outer loop is for positons of the string,
         once some of the regex matches from this position,
         it returns, so it gurantees the returned first matched index is
         indeed the first position some of the regex could match.
         */
        case positionLead
        /**
         When performing the search, the outer loop is for indexes of regex objects,
         and return the most left matched position,
         it also gurantees the return first matched index is the first position some of the regex could matches.
         */
        case regexLead
        /**
         When performing the search, the outer loop is for indexes of regex objects, once one regex matches, it returns,
         so it gurantees the returned matched regex is the first regex that matches,
         but the return first matched index might
         not be the first position some of the regex could matches.
         */
        case priorityToRegexOrder

        public var onigRegSetLead: OnigRegSetLead {
            switch self {
            case .positionLead:
                return ONIG_REGSET_POSITION_LEAD
            case .regexLead:
                return ONIG_REGSET_REGEX_LEAD
            case .priorityToRegexOrder:
                return ONIG_REGSET_PRIORITY_TO_REGEX_ORDER
            }
        }
    }
}

// MARK: RandomAccessCollection

extension RegexSet: RandomAccessCollection {
    public typealias Index = Int
    public typealias Element = Regex

    public var startIndex: Int {
        return 0
    }

    public var endIndex: Int {
        return Int(onig_regset_number_of_regex(self.rawValue))
    }

    public subscript(position: Int) -> Regex {
        return self.regexes[position]
    }
}
