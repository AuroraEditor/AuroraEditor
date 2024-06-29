//
//  RawGrammer.swift
//  Aurora Editor
//
//  Created by Nanashi Li on 2022/09/26.
//  Copyright © 2023 Aurora Company. All rights reserved.
//

import Foundation

// TODO: @0xWDG Look if this can be removed.
/// endRuleID: This is a special constant to indicate that the end regexp matched.
public var endRuleId = -1

/// whileRuleId: This is a special constant to indicate that the while regexp matched.
public var whileRuleId = -2

/// The representation of the raw grammar.
public struct RawGrammer: Codable {
    /// The repository of the grammar.
    var repository: [String: RawRule]?

    /// The name of the grammar.
    var scopeName: String

    /// The patterns of the grammar.
    var patterns: [RawRule]

    /// The injections of the grammar.
    var injections: [String: RawRule]?

    /// The injection selector of the grammar.
    var injectionSelector: String?

    /// The file types of the grammar.
    var fileTypes: [String]?

    /// The name of the grammar.
    var name: String?

    /// The first line match of the grammar.
    var firstLineMatch: String?

    /// Initialize the raw grammar.
    /// 
    /// - parameter repository: The repository of the grammar.
    /// - parameter scopeName: The name of the grammar.
    /// - parameter patterns: The patterns of the grammar.
    /// - parameter injections: The injections of the grammar.
    /// - parameter injectionSelector: The injection selector of the grammar.
    /// - parameter fileTypes: The file types of the grammar.
    /// - parameter name: The name of the grammar.
    /// - parameter firstLineMatch: The first line match of the grammar.
    init(repository: [String: RawRule]? = nil,
         scopeName: String,
         patterns: [RawRule],
         injections: [String: RawRule]? = nil,
         injectionSelector: String? = nil,
         fileTypes: [String]? = nil,
         name: String? = nil,
         firstLineMatch: String? = nil) {
        self.repository = repository
        self.scopeName = scopeName
        self.patterns = patterns
        self.injections = injections
        self.injectionSelector = injectionSelector
        self.fileTypes = fileTypes
        self.name = name
        self.firstLineMatch = firstLineMatch
    }
}

/// The representation of the raw rule.
public struct RawRule: Codable {
    /// The id of the rule.
    var id: UUID

    /// The include of the rule.
    var include: String?

    /// The name of the rule.
    var name: String?

    /// The content name of the rule.
    var contentName: String?

    /// The match of the rule.
    var match: String?

    /// The captures of the rule.
    var captures: [String: RawRule]?

    /// The begin of the rule.
    var begin: String?

    /// The begin captures of the rule.
    var beginCaptures: [String: RawRule]?

    /// The end of the rule.
    var end: String?

    /// The end captures of the rule.
    var endCaptures: [String: RawRule]?

    /// The while of the rule.
    var `while`: String?

    /// The while captures of the rule.
    var whileCpatures: [String: RawRule]?

    /// The patterns of the rule.
    var patterns: [RawRule]?

    /// The repository of the rule.
    var repository: [String: RawRule]?

    /// The apply end pattern last of the rule.
    var applyEndPatternLast: Bool?

    /// Initialize the raw rule.
    /// 
    /// - parameter include: The include of the rule.
    /// - parameter name: The name of the rule.
    /// - parameter contentName: The content name of the rule.
    /// - parameter match: The match of the rule.
    /// - parameter captures: The captures of the rule.
    /// - parameter begin: The begin of the rule.
    /// - parameter beginCaptures: The begin captures of the rule.
    /// - parameter end: The end of the rule.   
    /// - parameter endCaptures: The end captures of the rule.
    /// - parameter whileCpatures: The while captures of the rule.
    /// - parameter patterns: The patterns of the rule.
    /// - parameter repository: The repository of the rule.
    /// - parameter applyEndPatternLast: The apply end pattern last of the rule.
    init(include: String? = nil,
         name: String? = nil,
         contentName: String? = nil,
         match: String? = nil,
         captures: [String: RawRule]? = nil,
         begin: String? = nil,
         beginCaptures: [String: RawRule]? = nil,
         end: String? = nil,
         endCaptures: [String: RawRule]? = nil,
         whileCpatures: [String: RawRule]? = nil,
         patterns: [RawRule]? = nil,
         repository: [String: RawRule]? = nil,
         applyEndPatternLast: Bool? = nil) {
        self.id = UUID()
        self.include = include
        self.name = name
        self.contentName = contentName
        self.match = match
        self.captures = captures
        self.begin = begin
        self.beginCaptures = beginCaptures
        self.end = end
        self.endCaptures = endCaptures
        self.whileCpatures = whileCpatures
        self.patterns = patterns
        self.repository = repository
        self.applyEndPatternLast = applyEndPatternLast
    }
}

extension Rule {
    /// Equate
    /// 
    /// - parameter lhs: The left hand side rule.
    /// - parameter rhs: The right hand side rule.
    /// 
    /// - returns: true if equal
    static func == (lhs: Rule, rhs: Rule) -> Bool {
        guard type(of: lhs) == type(of: rhs) else { return false }
        return lhs.id == rhs.id
    }

    /// Not equal
    /// 
    /// - parameter lhs: The left hand side rule.
    /// - parameter rhs: The right hand side rule.
    /// 
    /// - returns: true if not equal
    static func != (lhs: Rule, rhs: Rule) -> Bool {
        return !(lhs == rhs)
    }
}
