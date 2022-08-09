//
//  Array.swift
//  AuroraEditor
//
//  Created by Nanashi Li on 2022/08/09.
//  Copyright © 2022 Aurora Company. All rights reserved.
//

import Foundation

extension Array {
    subscript (safe index: Int) -> Element? {
        return indices ~= index ? self[index] : nil
    }
}
