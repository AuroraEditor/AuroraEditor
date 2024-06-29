//
//  ThemeAttribute+Error.swift
//  Aurora Editor
//
//  Created by Matthew Davidson on 17/12/19.
//  Copyright © 2023 Aurora Company. All rights reserved.
//

import Foundation
import OSLog

extension ThemeAttribute {

    func error(_ details: String = "") {
        let logger = Logger(subsystem: "com.auroraeditor", category: "Theme Attribute")
        logger.fault("Failed to apply ThemeAttribute '\(key)'. \(details)")
    }
}
