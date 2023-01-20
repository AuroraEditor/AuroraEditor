//
//  BracketCount.swift
//  Aurora Editor
//
//  Created by Kai Quan Tay on 10/11/22.
//  Copyright © 2023 Aurora Company. All rights reserved.
//

import Foundation

/// The location (line, column) of the cursor in the editor view
///
/// - Note: Not yet implemented
public struct BracketCount {
    /// Round bracket count
    public var roundBracketCount: Int
    /// Curly bracket count
    public var curlyBracketCount: Int
    /// Square bracket count
    public var squareBracketCount: Int

    /// History
    public var bracketHistory: [BracketType]
}

/// Bracket type
public enum BracketType {
    /// Round
    case round
    /// Curly
    case curly
    /// Square
    case square
}

/// Bracket display yype
public enum BracketDisplayType {
    /// Seperated
    case seperated
    /// Textual
    case textual
}
