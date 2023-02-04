//
//  Severity.swift
//  Aurora Editor
//
//  Created by Nanashi Li on 03/02/2023.
//  Copyright © 2023 Aurora Company. All rights reserved.
//

import Foundation

enum Severity: Int {
    case ignore = 0
    case info = 1
    case warning = 2
    case error = 3
}

extension Severity {

    /// Parses 'error', 'warning', 'warn', 'info' in call casings
    /// and falls back to ignore.
    public func fromValue(value: String) -> Severity {
        if value.isEmpty {
            return .ignore
        }

        if value == "error" {
            return .error
        }

        if value == "warning" || value == "warn" {
            return .warning
        }

        if value == "info" {
            return .info
        }

        return .ignore
    }

    /// Converts the serverity enum into a string
    public func toString(severity: Severity) -> String {
        switch severity {
        case .error:
            return "error"
        case .warning:
            return "warning"
        case .info:
            return "info"
        default:
            return "ignore"
        }
    }
}
