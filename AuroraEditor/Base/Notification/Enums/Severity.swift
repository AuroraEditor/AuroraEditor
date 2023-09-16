//
//  Severity.swift
//  Aurora Editor
//
//  Created by Nanashi Li on 16/09/2023.
//  Copyright © 2023 Aurora Company. All rights reserved.
//

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

    /// 
    public func iconName() -> String {
        switch self {
        case .error:
            return "xmark.circle.fill"
        case .warning:
            return "exclamationmark.triangle.fill"
        case .ignore:
            return ""
        case .info:
            return ""
        }
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
