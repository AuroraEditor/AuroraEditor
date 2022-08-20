//
//  Collection.swift
//  AuroraEditor
//
//  Created by Nanashi Li on 2022/08/09.
//  Copyright © 2022 Aurora Company. All rights reserved.
//

import Foundation

extension Collection where Indices.Iterator.Element == Index {
   public subscript(safe index: Index) -> Iterator.Element? {
     return (startIndex <= index && index < endIndex) ? self[index] : nil
   }
}
