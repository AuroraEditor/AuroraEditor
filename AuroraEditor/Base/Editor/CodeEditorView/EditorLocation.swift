//
//  Location.swift
//  
//
//  Created by Manuel M T Chakravarty on 09/05/2021.
//

import Foundation
import System

/// Location in a text file.
///
public struct Location {
  public let file: FilePath
  public let line: Int
  public let column: Int

  public init(file: FilePath, line: Int, column: Int) {
    self.file = file
    self.line = line
    self.column = column
  }
}

/// Generic location attribute.
///
public struct Located<Entity> {
  public let location: Location
  public let entity: Entity

  public init(location: Location, entity: Entity) {
    self.location = location
    self.entity   = entity
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
///
public struct Span {
  public let start: Location
  public let endLine: Int
  public let endColumn: Int

  public init(start: Location, endLine: Int, endColumn: Int) {
    self.start = start
    self.endLine = endLine
    self.endColumn = endColumn
  }
}
