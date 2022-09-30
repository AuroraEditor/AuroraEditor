//
//  NSRange+Shifted.swift
//  
//
//  Created by Matthew Davidson on 4/1/20.
//

import Foundation

public extension NSRange {

    func shifted(by amount: Int) -> NSRange {
        return NSRange(location: location + amount, length: length)
    }
}
