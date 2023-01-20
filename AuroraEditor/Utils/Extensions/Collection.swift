//
//  Collection.swift
//  Aurora Editor
//
//  Created by Nanashi Li on 2022/08/09.
//

import Foundation

extension Collection where Indices.Iterator.Element == Index {
    /// Subscript collection
    /// - Parameters:
    ///    - index: The inde
    /// - Returns: Element
    public subscript(safe index: Index) -> Iterator.Element? {
      return (startIndex <= index && index < endIndex) ? self[index] : nil
    }
}
