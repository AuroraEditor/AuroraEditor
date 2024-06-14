//
//  LanguageType.swift
//  Aurora Editor
//
//  Created by Nanashi Li on 2022/04/17.
//  Copyright © 2023 Aurora Company. All rights reserved.
//

import Foundation

/// Language type
struct LanguageType: Identifiable, Hashable {

    /// Name
    let name: String

    /// Extension
    let ext: String

    /// Identifier
    var id: String {
        ext.lowercased().removingSpaces()
    }
}
