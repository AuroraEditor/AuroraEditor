//
//  RawGrammer.swift
//  
//
//  Created by Nanashi Li on 2022/09/26.
//

import Foundation

// This is a special constant to indicate that the end regexp matched.
public var endRuleId = -1

// This is a special constant to indicate that the while regexp matched.
public var whileRuleId = -2

public protocol RawGrammer: Codable {
    var repository: [String: RawRule]? { get set }
    var scopeName: String { get set }
    var patterns: [RawRule] { get set }
    var injections: [String: RawRule]? { get set }
    var injectionSelector: String? { get set }

    var fileTypes: [String]? { get set }
    var name: String? { get set }
    var firstLineMatch: String? { get set }
}

public protocol RawRule: Codable {
    var id: UUID { get set }
    var include: String? { get }

    var name: String? { get }
    var contentName: String? { get }

    var match: String? { get }
    var captures: [String: RawRule]? { get }
    var begin: String? { get }
    var beginCaptures: [String: RawRule]? { get }
    var end: String? { get }
    var endCaptures: [String: RawRule]? { get }
    var `while`: String? { get }
    var whileCpatures: [String: RawRule]? { get }
    var patterns: [RawRule]? { get }

    var repository: [String: RawRule]? { get }

    var applyEndPatternLast: Bool? { get }
}
