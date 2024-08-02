//
//  Sequence.swift
//  Aurora Editor
//
//  Created by Wesley de Groot on 02/08/2024.
//  Copyright © 2024 Aurora Company. All rights reserved.
//

import Foundation

extension Sequence where Iterator.Element: Hashable {
    func unique() -> [Iterator.Element] {
        var seen: Set<Iterator.Element> = []
        return filter { seen.insert($0).inserted }
    }
}
