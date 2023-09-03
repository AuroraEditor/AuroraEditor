//
//  CursorLocation.swift
//  Aurora Editor
//
//  Created by Lukas Pistrol on 11.05.22.
//  Copyright © 2023 Aurora Company. All rights reserved.
//
//  This file originates from CodeEdit, https://github.com/CodeEditApp/CodeEdit

import Foundation

/// The location (line, column) of the cursor in the editor view
///
/// - Note: Not yet implemented
public struct CursorLocation {
    /// The current line the cursor is located at.
    public var line: Int
    /// The current column the cursor is located at.
    public var column: Int
}
