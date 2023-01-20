//
//  LanguageType.swift
//  Aurora Editor
//
//  Created by Nanashi Li on 2022/04/17.
//

import Foundation

struct LanguageType: Identifiable, Hashable {
    let name: String
    let ext: String
    var id: String {
        ext.lowercased().removingSpaces()
    }
}
