//
//  ThemeAttribute+Error.swift
//  Aurora Editor
//
//  Created by Matthew Davidson on 17/12/19.
//  Copyright © 2023 Aurora Company. All rights reserved.
//

import Foundation

extension ThemeAttribute {

    func error(_ details: String = "") {
        Log.error("Failed to apply ThemeAttribute '\(key)'. \(details)")
    }
}
