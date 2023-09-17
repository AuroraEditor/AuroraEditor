//
//  Severity.swift
//  Aurora Editor
//
//  Created by Nanashi Li on 16/09/2023.
//  Copyright © 2023 Aurora Company. All rights reserved.
//

/// An enumeration specifying severity levels for notifications.
enum Severity: Int {
    /// Indicates that the notification should be ignored.
    case ignore = 0

    /// Indicates an informational severity level for notifications.
    case info = 1

    /// Indicates a warning severity level for notifications.
    case warning = 2

    /// Indicates an error severity level for notifications.
    case error = 3
}

extension Severity {
    /// Parses a string value and returns the corresponding `Severity`.
    /// Recognizes common variants of severity strings and falls back to `.ignore` if not recognized.
    ///
    /// - Parameter value: The string representation of the severity.
    /// - Returns: The parsed `Severity` value.
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

    /// Returns the name of the system icon associated with the severity.
    ///
    /// - Returns: The name of the system icon.
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

    /// Converts a `Severity` enum value into its string representation.
    ///
    /// - Parameter severity: The `Severity` value to convert.
    /// - Returns: The string representation of the `Severity`.
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
