//
//  ManualConflictResolution.swift
//  Aurora Editor
//
//  Created by Nanashi Li on 2022/08/15.
//  This source code is restricted for Aurora Editor usage only.
//

import Foundation

// NOTE: These strings have semantic value, they're passed directly
// as `--ours` and `--theirs` to git checkout. Please be careful
// when modifying this type.
enum ManualConflictResolution {
    case theirs
    case ours
}
