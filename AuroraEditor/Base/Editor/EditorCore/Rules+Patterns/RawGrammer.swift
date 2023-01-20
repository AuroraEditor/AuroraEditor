//
//  RawGrammer.swift
//  Aurora Editor
//
//  Created by Nanashi Li on 2022/09/26.
//  Copyright © 2023 Aurora Company. All rights reserved.
//

import Foundation

/// endRuleID: This is a special constant to indicate that the end regexp matched.
public var endRuleId = -1

/// whileRuleId: This is a special constant to indicate that the while regexp matched.
public var whileRuleId = -2

public struct RawGrammer: Codable {
    var repository: [String: RawRule]?
    var scopeName: String
    var patterns: [RawRule]
    var injections: [String: RawRule]?
    var injectionSelector: String?

    var fileTypes: [String]?
    var name: String?
    var firstLineMatch: String?

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

public struct RawRule: Codable {
    var id: UUID
    var include: String?

    var name: String?
    var contentName: String?

    var match: String?
    var captures: [String: RawRule]?
    var begin: String?
    var beginCaptures: [String: RawRule]?
    var end: String?
    var endCaptures: [String: RawRule]?
    var `while`: String?
    var whileCpatures: [String: RawRule]?
    var patterns: [RawRule]?

    var repository: [String: RawRule]?

    var applyEndPatternLast: Bool?

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
    static func == (lhs: Rule, rhs: Rule) -> Bool {
        guard type(of: lhs) == type(of: rhs) else { return false }
        return lhs.id == rhs.id
    }

    static func != (lhs: Rule, rhs: Rule) -> Bool {
        return !(lhs == rhs)
    }
}
