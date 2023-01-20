//
//  Location.swift
//  Aurora Editor
//
//  Created by Manuel M T Chakravarty on 09/05/2021.
//  Copyright © 2023 Aurora Company. All rights reserved.
//

import Foundation
import System

/// Location in a text file.
public struct Location {
    /// Fi;le
    public let file: FilePath
    /// Line
    public let line: Int
    /// Column
    public let column: Int

    /// Initialize location
    /// - Parameters:
    ///   - file: file
    ///   - line: line
    ///   - column: column
    public init(file: FilePath, line: Int, column: Int) {
        self.file = file
        self.line = line
        self.column = column
    }
}

/// Generic location attribute.
public struct Located<Entity> {
    /// Location
    public let location: Location
    /// Entity
    public let entity: Entity

    /// Initialize
    /// - Parameters:
    ///   - location: location
    ///   - entity: Entity
    public init(location: Location, entity: Entity) {
        self.location = location
        self.entity = entity
    }
}

extension Located: Equatable where Entity: Equatable {
    public static func == (lhs: Located<Entity>, rhs: Located<Entity>) -> Bool {
        lhs.entity == rhs.entity
    }
}

extension Located: Hashable where Entity: Hashable {
    public func hash(into hasher: inout Hasher) { hasher.combine(entity) }
}

/// Character span in a text file.
public struct Span {
    /// Start location
    public let start: Location
    /// End line
    public let endLine: Int
    /// End Column
    public let endColumn: Int

    /// Init Span
    /// - Parameters:
    ///   - start: start location
    ///   - endLine: end line
    ///   - endColumn: end column
    public init(start: Location, endLine: Int, endColumn: Int) {
        self.start = start
        self.endLine = endLine
        self.endColumn = endColumn
    }
}
