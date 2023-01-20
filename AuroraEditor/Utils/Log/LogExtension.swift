//
//  LogExtension.swift
//  Aurora Editor
//
//  Created by Nanashi Li on 2022/08/04.
//  Copyright © 2023 Aurora Company. All rights reserved.
//

import Foundation
import SwiftUI

private let log = Log()

extension Log {
    /// Log level
    /// - Parameter minLevel: minimum level
    public static func minLogLevel(_ minLevel: Level) {
        log.minLevel = minLevel
    }

    /// Info log message
    /// - Parameters:
    ///   - logMessage: message
    ///   - file: file
    ///   - line: line
    ///   - funct: function
    public static func info(_ logMessage: Any...,
                            file: String = #file,
                            line: Int = #line,
                            funct: String = #function) {
        log.info(logMessage, file: file, line: line, function: funct)
    }

    /// debug log message
    /// - Parameters:
    ///   - logMessage: message
    ///   - file: file
    ///   - line: line
    ///   - funct: function
    public static func debug(_ logMessage: Any...,
                             file: String = #file,
                             line: Int = #line,
                             funct: String = #function) {
        log.debug(logMessage, file: file, line: line, function: funct)
    }

    /// warning log message
    /// - Parameters:
    ///   - logMessage: message
    ///   - file: file
    ///   - line: line
    ///   - funct: function
    public static func warning(_ logMessage: Any...,
                               file: String = #file,
                               line: Int = #line,
                               funct: String = #function) {
        log.warning(logMessage, file: file, line: line, function: funct)
    }

    /// trace log message
    /// - Parameters:
    ///   - logMessage: message
    ///   - file: file
    ///   - line: line
    ///   - funct: function
    public static func trace(_ logMessage: Any...,
                             file: String = #file,
                             line: Int = #line,
                             funct: String = #function) {
        log.trace(logMessage, file: file, line: line, function: funct)
    }

    /// error log message
    /// - Parameters:
    ///   - logMessage: message
    ///   - file: file
    ///   - line: line
    ///   - funct: function
    public static func error(_ logMessage: Any...,
                             file: String = #file,
                             line: Int = #line,
                             funct: String = #function) {
        log.error(logMessage, file: file, line: line, function: funct)
    }
}

extension View {
    /// Info log message
    /// - Parameters:
    ///   - logMessage: message
    ///   - file: file
    ///   - line: line
    ///   - funct: function
    public func info(_ logMessage: Any...,
                     file: String = #file,
                     line: Int = #line,
                     funct: String = #function) -> some View {
        log.info(logMessage, file: file, line: line, function: funct)
        return EmptyView()
    }

    /// debug log message
    /// - Parameters:
    ///   - logMessage: message
    ///   - file: file
    ///   - line: line
    ///   - funct: function
    public func debug(_ logMessage: Any...,
                      file: String = #file,
                      line: Int = #line,
                      funct: String = #function) -> some View {
        log.debug(logMessage, file: file, line: line, function: funct)
        return EmptyView()
    }

    /// warning log message
    /// - Parameters:
    ///   - logMessage: message
    ///   - file: file
    ///   - line: line
    ///   - funct: function
    public func warning(_ logMessage: Any...,
                        file: String = #file,
                        line: Int = #line,
                        funct: String = #function) -> some View {
        log.warning(logMessage, file: file, line: line, function: funct)
        return EmptyView()
    }

    /// trace log message
    /// - Parameters:
    ///   - logMessage: message
    ///   - file: file
    ///   - line: line
    ///   - funct: function
    public func trace(_ logMessage: Any...,
                      file: String = #file,
                      line: Int = #line,
                      funct: String = #function) -> some View {
        log.trace(logMessage, file: file, line: line, function: funct)
        return EmptyView()
    }

    /// error log message
    /// - Parameters:
    ///   - logMessage: message
    ///   - file: file
    ///   - line: line
    ///   - funct: function
    public func error(_ logMessage: Any...,
                      file: String = #file,
                      line: Int = #line,
                      funct: String = #function) -> some View {
        log.error(logMessage, file: file, line: line, function: funct)
        return EmptyView()
    }
}
