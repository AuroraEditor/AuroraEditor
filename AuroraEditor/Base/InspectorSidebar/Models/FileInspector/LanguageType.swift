//
//  LanguageType.swift
//  AuroraEditor
//
//  Created by Nanashi Li on 2022/04/17.
//

import Foundation

struct LanguageType: Identifiable, Hashable {
    let name: String
    var id: String {
        name.lowercased().removingSpaces()
    }
}
