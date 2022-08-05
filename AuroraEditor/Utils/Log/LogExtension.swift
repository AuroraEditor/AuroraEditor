//
//  LogExtension.swift
//  AuroraEditor
//
//  Created by Nanashi Li on 2022/08/04.
//  Copyright © 2022 Aurora Company. All rights reserved.
//

import Foundation
import SwiftUI

private let log = Log()

extension Log {
    public static func minLogLevel(_ minLevel: Level) {
        log.minLevel = minLevel
    }

    public static func info(_ logMessage: Any...,
                            file: String = #file,
                            line: Int = #line,
                            funct: String = #function) {
        log.info(logMessage, file: file, line: line, function: funct)
    }

    public static func debug(_ logMessage: Any...,
                             file: String = #file,
                             line: Int = #line,
                             funct: String = #function) {
        log.debug(logMessage, file: file, line: line, function: funct)
    }

    public static func warning(_ logMessage: Any...,
                               file: String = #file,
                               line: Int = #line,
                               funct: String = #function) {
        log.warning(logMessage, file: file, line: line, function: funct)
    }

    public static func trace(_ logMessage: Any...,
                             file: String = #file,
                             line: Int = #line,
                             funct: String = #function) {
        log.trace(logMessage, file: file, line: line, function: funct)
    }

    public static func error(_ logMessage: Any...,
                             file: String = #file,
                             line: Int = #line,
                             funct: String = #function) {
        log.error(logMessage, file: file, line: line, function: funct)
    }
}

extension View {

    public static func info(_ logMessage: Any...,
                            file: String = #file,
                            line: Int = #line,
                            funct: String = #function) -> some View {
        log.info(logMessage, file: file, line: line, function: funct)
        return EmptyView()
    }

    public static func debug(_ logMessage: Any...,
                             file: String = #file,
                             line: Int = #line,
                             funct: String = #function) -> some View {
        log.debug(logMessage, file: file, line: line, function: funct)
        return EmptyView()
    }

    public static func warning(_ logMessage: Any...,
                               file: String = #file,
                               line: Int = #line,
                               funct: String = #function) -> some View {
        log.warning(logMessage, file: file, line: line, function: funct)
        return EmptyView()
    }

    public static func trace(_ logMessage: Any...,
                             file: String = #file,
                             line: Int = #line,
                             funct: String = #function) -> some View {
        log.trace(logMessage, file: file, line: line, function: funct)
        return EmptyView()
    }

    public static func error(_ logMessage: Any...,
                             file: String = #file,
                             line: Int = #line,
                             funct: String = #function) -> some View {
        log.error(logMessage, file: file, line: line, function: funct)
        return EmptyView()
    }
}
