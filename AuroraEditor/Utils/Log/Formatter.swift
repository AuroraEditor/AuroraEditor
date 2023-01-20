//
//  Formatter.swift
//  Aurora Editor
//
//  Created by Nanashi Li on 2022/08/04.
//  Copyright © 2023 Aurora Company. All rights reserved.
//

import Foundation

/// Components
public enum Component {
    /// Date
    case date(String)
    /// Message
    case message
    /// Level
    case level
    /// File
    case file(fullPath: Bool, fileExtension: Bool)
    /// Line
    case line
    /// Column
    case column
    /// Function
    case function
    /// Location
    case location
    /// Block
    case block(() -> Any?)
}

/// Formatters
open class Formatters {}

open class Formatter: Formatters {
    /// The formatter format.
    private var format: String

    /// The formatter components.
    private var components: [Component]

    /// The date formatter.
    private let dateFormatter = DateFormatter()

    /// The formatter logger.
    weak var logger: Log?

    /// The formatter textual representation.
    var description: String {
        return String(format: format, arguments: components.map { (component: Component) -> CVarArg in
            return String(describing: component).uppercased()
        })
    }

    /**
     Creates and returns a new formatter with the specified format and components.

     - parameter format:     The formatter format.
     - parameter components: The formatter components.

     - returns: A newly created formatter.
     */
    public convenience init(_ format: String, _ components: Component...) {
        self.init(format, components)
    }

    /**
     Creates and returns a new formatter with the specified format and components.

     - parameter format:     The formatter format.
     - parameter components: The formatter components.

     - returns: A newly created formatter.
     */
    public init(_ format: String, _ components: [Component]) {
        self.format = format
        self.components = components
    }

    /**
     Formats a string with the formatter format and components.

     - parameter level:      The severity level.
     - parameter items:      The items to format.
     - parameter separator:  The separator between the items.
     - parameter terminator: The terminator of the formatted string.
     - parameter file:       The log file path.
     - parameter line:       The log line number.
     - parameter column:     The log column number.
     - parameter function:   The log function.
     - parameter date:       The log date.

     - returns: A formatted string.
     */
    func format(level: Level, // swiftlint:disable:this function_parameter_count
                items: [Any],
                separator: String,
                terminator: String,
                file: String,
                line: Int,
                column: Int,
                function: String,
                date: Date) -> String {
        let arguments = components.map { (component: Component) -> CVarArg in
            switch component {
            case let .date(dateFormat):
                return format(date: date, dateFormat: dateFormat)
            case let .file(fullPath, fileExtension):
                return format(file: file, fullPath: fullPath, fileExtension: fileExtension)
            case .function:
                return String(function)
            case .line:
                return String(line)
            case .column:
                return String(column)
            case .level:
                return format(level: level)
            case .message:
                return items.map({ String(describing: $0) }).joined(separator: separator)
            case .location:
                return format(file: file, line: line)
            case let .block(block):
                return block().flatMap({ String(describing: $0) }) ?? ""
            }
        }
        return String(format: format, arguments: arguments) + terminator
    }

    /**
     Formats a string with the formatter format and components.

     - parameter description:               The measure description.
     - parameter average:                   The average time.
     - parameter relativeStandardDeviation: The relative standard description.
     - parameter file:                      The log file path.
     - parameter line:                      The log line number.
     - parameter column:                    The log column number.
     - parameter function:                  The log function.
     - parameter date:                      The log date.

     - returns: A formatted string.
     */
    func format(description: String?, // swiftlint:disable:this function_parameter_count
                average: Double,
                relativeStandardDeviation: Double,
                file: String,
                line: Int,
                column: Int,
                function: String,
                date: Date) -> String {

        let arguments = components.map { (component: Component) -> CVarArg in
            switch component {
            case let .date(dateFormat):
                return format(date: date, dateFormat: dateFormat)
            case let .file(fullPath, fileExtension):
                return format(file: file, fullPath: fullPath, fileExtension: fileExtension)
            case .function:
                return String(function)
            case .line:
                return String(line)
            case .column:
                return String(column)
            case .level:
                return format(description: description)
            case .message:
                return format(average: average, relativeStandardDeviation: relativeStandardDeviation)
            case .location:
                return format(file: file, line: line)
            case let .block(block):
                return block().flatMap({ String(describing: $0) }) ?? ""
            }
        }
        return String(format: format, arguments: arguments)
    }
}

private extension Formatter {
    /**
     Formats a date with the specified date format.

     - parameter date:       The date.
     - parameter dateFormat: The date format.

     - returns: A formatted date.
     */
    func format(date: Date, dateFormat: String) -> String {
        dateFormatter.dateFormat = dateFormat
        return dateFormatter.string(from: date)
    }

    /**
     Formats a file path with the specified parameters.

     - parameter file:          The file path.
     - parameter fullPath:      Whether the full path should be included.
     - parameter fileExtension: Whether the file extension should be included.

     - returns: A formatted file path.
     */
    func format(file: String, fullPath: Bool, fileExtension: Bool) -> String {
        var file = file

        if !fullPath { file = file.lastPathComponent }
        if !fileExtension { file = file.stringByDeletingPathExtension }

        return file
    }

    /**
     Formats a Location component with a specified file path and line number.

     - parameter file: The file path.
     - parameter line: The line number.

     - returns: A formatted Location component.
     */
    func format(file: String, line: Int) -> String {
        return [
            format(file: file, fullPath: false, fileExtension: true),
            String(line)
        ].joined(separator: ":")
    }

    /**
     Formats a Level component.

     - parameter level: The Level component.

     - returns: A formatted Level component.
     */
    func format(level: Level) -> String {
        let text = level.description
        return text
    }

    /**
     Formats a measure description.

     - parameter description: The measure description.

     - returns: A formatted measure description.
     */
    func format(description: String?) -> String {
        var text = "MEASURE"

        if let description = description {
            text = "\(text) \(description)"
        }
        return text
    }

    /**
     Formats an average time and a relative standard deviation.

     - parameter average:                   The average time.
     - parameter relativeStandardDeviation: The relative standard deviation.

     - returns: A formatted average time and relative standard deviation.
     */
    func format(average: Double, relativeStandardDeviation: Double) -> String {
        let average = format(average: average)
        let relativeStandardDeviation = format(relativeStandardDeviation: relativeStandardDeviation)
        return "Time: \(average) sec (\(relativeStandardDeviation) STDEV)"
    }

    /**
     Formats an average time.

     - parameter average: An average time.

     - returns: A formatted average time.
     */
    func format(average: Double) -> String {
        return String(format: "%.3f", average)
    }

    /**
     Formats a list of durations.

     - parameter durations: A list of durations.

     - returns: A formatted list of durations.
     */
    func format(durations: [Double]) -> String {
        var format = Array(repeating: "%.6f", count: durations.count).joined(separator: ", ")
        format = "[\(format)]"
        return String(format: format, arguments: durations.map { $0 as CVarArg })
    }

    /**
     Formats a standard deviation.

     - parameter standardDeviation: A standard deviation.

     - returns: A formatted standard deviation.
     */
    func format(standardDeviation: Double) -> String {
        return String(format: "%.6f", standardDeviation)
    }

    /**
     Formats a relative standard deviation.

     - parameter relativeStandardDeviation: A relative standard deviation.

     - returns: A formatted relative standard deviation.
     */
    func format(relativeStandardDeviation: Double) -> String {
        return String(format: "%.3f%%", relativeStandardDeviation)
    }
}
