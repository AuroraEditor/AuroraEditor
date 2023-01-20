//
//  NSRange+Shifted.swift
//  Aurora Editor
//
//  Created by Matthew Davidson on 4/1/20.
//

import Foundation

public extension NSRange {
    /// Shift NSRange
    /// - Parameter amount: by amount
    /// - Returns: Shifted NSRange
    func shifted(by amount: Int) -> NSRange {
        return NSRange(location: location + amount, length: length)
    }
}
