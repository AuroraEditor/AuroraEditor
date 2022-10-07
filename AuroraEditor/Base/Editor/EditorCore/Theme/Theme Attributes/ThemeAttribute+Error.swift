//
//  ThemeAttribute+Error.swift
//  
//
//  Created by Matthew Davidson on 17/12/19.
//

import Foundation

extension ThemeAttribute {

    func error(_ details: String = "") {
        log("Failed to apply ThemeAttribute '\(key)'. \(details)")
    }
}
