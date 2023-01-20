//
//  Dictionary+Additions.swift
//  Aurora Editor
//
//  Created by Nanashi Li on 2022/03/31.
//  Copyright © 2023 Aurora Company. All rights reserved.
//

import Foundation

internal func += <KeyType, ValueType> (
    left: inout [KeyType: ValueType],
    right: [KeyType: ValueType]) {

    for (key, val) in right {
        left.updateValue(val, forKey: key)
    }
}
