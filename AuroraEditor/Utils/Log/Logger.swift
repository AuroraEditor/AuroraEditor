//
//  Logger.swift
//  AuroraEditor
//
//  Created by Nanashi Li on 2022/08/04.
//  Copyright © 2022 Aurora Company. All rights reserved.
//

import Foundation

private let benchmarker = Benchmarker()

public enum Level: Int {
    case trace, debug, info, warning, error

    var description: String {
        return String(describing: self).uppercased()
    }
}

extension Level: Comparable {
    public static func < (lhs: Level, rhs: Level) -> Bool {
        return lhs.rawValue < rhs.rawValue
    }
}

public class Logger {
    /// The logger state.
    public var enabled: Bool = true

    /// The logger formatter.
    public var formatter: Formatter {
        didSet { formatter.logger = self }
    }

    /// The minimum level of severity.
    public var minLevel: Level

    /// The logger format.
    public var format: String {
        return formatter.description
    }

    /// The queue used for logging.
    private let queue = DispatchQueue(label: "delba.log")

    /**
     Creates and returns a new logger.

     - parameter formatter: The formatter.
     - parameter theme:     The theme.
     - parameter minLevel:  The minimum level of severity.

     - returns: A newly created logger.
     */
    public init(formatter: Formatter = .default, minLevel: Level = .trace) {
        self.formatter = formatter
        self.minLevel = minLevel

        formatter.logger = self
    }

    /**
     Logs a message with a trace severity level.

     - parameter items:      The items to log.
     - parameter separator:  The separator between the items.
     - parameter terminator: The terminator of the log message.
     - parameter file:       The file in which the log happens.
     - parameter line:       The line at which the log happens.
     - parameter column:     The column at which the log happens.
     - parameter function:   The function in which the log happens.
     */
    public func trace(_ items: Any...,
                      separator: String = " ",
                      terminator: String = "\n",
                      file: String = #file,
                      line: Int = #line,
                      column: Int = #column,
                      function: String = #function) {
        log(.trace, items, separator, terminator, file, line, column, function)
    }

    /**
     Logs a message with a debug severity level.

     - parameter items:      The items to log.
     - parameter separator:  The separator between the items.
     - parameter terminator: The terminator of the log message.
     - parameter file:       The file in which the log happens.
     - parameter line:       The line at which the log happens.
     - parameter column:     The column at which the log happens.
     - parameter function:   The function in which the log happens.
     */
    public func debug(_ items: Any...,
                      separator: String = " ",
                      terminator: String = "\n",
                      file: String = #file,
                      line: Int = #line,
                      column: Int = #column,
                      function: String = #function) {
        log(.debug, items, separator, terminator, file, line, column, function)
    }

    /**
     Logs a message with an info severity level.

     - parameter items:      The items to log.
     - parameter separator:  The separator between the items.
     - parameter terminator: The terminator of the log message.
     - parameter file:       The file in which the log happens.
     - parameter line:       The line at which the log happens.
     - parameter column:     The column at which the log happens.
     - parameter function:   The function in which the log happens.
     */
    public func info(_ items: Any...,
                     separator: String = " ",
                     terminator: String = "\n",
                     file: String = #file,
                     line: Int = #line,
                     column: Int = #column,
                     function: String = #function) {
        log(.info, items, separator, terminator, file, line, column, function)
    }

    /**
     Logs a message with a warning severity level.

     - parameter items:      The items to log.
     - parameter separator:  The separator between the items.
     - parameter terminator: The terminator of the log message.
     - parameter file:       The file in which the log happens.
     - parameter line:       The line at which the log happens.
     - parameter column:     The column at which the log happens.
     - parameter function:   The function in which the log happens.
     */
    public func warning(_ items: Any...,
                        separator: String = " ",
                        terminator: String = "\n",
                        file: String = #file,
                        line: Int = #line,
                        column: Int = #column,
                        function: String = #function) {
        log(.warning, items, separator, terminator, file, line, column, function)
    }

    /**
     Logs a message with an error severity level.

     - parameter items:      The items to log.
     - parameter separator:  The separator between the items.
     - parameter terminator: The terminator of the log message.
     - parameter file:       The file in which the log happens.
     - parameter line:       The line at which the log happens.
     - parameter column:     The column at which the log happens.
     - parameter function:   The function in which the log happens.
     */
    public func error(_ items: Any...,
                      separator: String = " ",
                      terminator: String = "\n",
                      file: String = #file,
                      line: Int = #line,
                      column: Int = #column,
                      function: String = #function) {
        log(.error, items, separator, terminator, file, line, column, function)
    }

    /**
     Logs a message.

     - parameter level:      The severity level.
     - parameter items:      The items to log.
     - parameter separator:  The separator between the items.
     - parameter terminator: The terminator of the log message.
     - parameter file:       The file in which the log happens.
     - parameter line:       The line at which the log happens.
     - parameter column:     The column at which the log happens.
     - parameter function:   The function in which the log happens.
     */
    // swiftlint:disable:next function_parameter_count
    private func log(_ level: Level,
                     _ items: [Any],
                     _ separator: String,
                     _ terminator: String,
                     _ file: String,
                     _ line: Int,
                     _ column: Int,
                     _ function: String) {
        guard enabled && level >= minLevel else { return }

        let date = Date()

        let result = formatter.format(
            level: level,
            items: items,
            separator: separator,
            terminator: terminator,
            file: file,
            line: line,
            column: column,
            function: function,
            date: date
        )

        queue.async {
            Swift.print(result, separator: "", terminator: "")
        }
    }

    /**
     Measures the performance of code.

     - parameter description: The measure description.
     - parameter number:      The number of iterations.
     - parameter file:        The file in which the measure happens.
     - parameter line:        The line at which the measure happens.
     - parameter column:      The column at which the measure happens.
     - parameter function:    The function in which the measure happens.
     - parameter block:       The block to measure.
     */
    public func measure(_ description: String? = nil,
                        iterations number: Int = 10,
                        file: String = #file,
                        line: Int = #line,
                        column: Int = #column,
                        function: String = #function,
                        block: () -> Void) {
        guard enabled && .debug >= minLevel else { return }

        let measure = benchmarker.measure(description, iterations: number, block: block)

        let date = Date()

        let result = formatter.format(
            description: measure.description,
            average: measure.average,
            relativeStandardDeviation: measure.relativeStandardDeviation,
            file: file,
            line: line,
            column: column,
            function: function,
            date: date
        )

        queue.async {
            Swift.print(result)
        }
    }
}
