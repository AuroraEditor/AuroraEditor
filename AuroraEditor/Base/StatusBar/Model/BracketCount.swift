//
//  BracketCount.swift
//  AuroraEditor
//
//  Created by Kai Quan Tay on 10/11/22.
//  Copyright © 2022 Aurora Company. All rights reserved.
//

import Foundation

/// The location (line, column) of the cursor in the editor view
///
/// - Note: Not yet implemented
public struct BracketCount {
    public var roundBracketCount: Int
    public var curlyBracketCount: Int
    public var squareBracketCount: Int

    public var bracketHistory: [BracketType]
}

public enum BracketType {
    case round
    case curly
    case square
}

public enum BracketDisplayType {
    case seperated
    case textual
}
