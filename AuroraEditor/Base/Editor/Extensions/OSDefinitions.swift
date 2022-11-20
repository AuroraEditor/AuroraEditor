//
//  OSDefinitions.swift
//  
//
//  Created by Manuel M T Chakravarty on 04/05/2021.
//
//  A set of aliases and the like to smooth ove some superficial macOS/iOS differences.

import SwiftUI

let labelColor = NSColor.labelColor

typealias TextStorageEditActions = NSTextStorageEditActions

extension NSColor {

    /// Create an AppKit colour from a SwiftUI colour if possible.
    convenience init?(color: Color) {
        guard let cgColor = color.cgColor else { return nil }
        self.init(cgColor: cgColor)
    }
}
