//
//  TerminalEmulatorView+Coordinator.swift
//  Aurora Editor
//
//  Created by Lukas Pistrol on 24.03.22.
//  Copyright © 2023 Aurora Company. All rights reserved.
//

import SwiftUI
import SwiftTerm

/// Coordinator for the terminal emulator view.
public extension TerminalEmulatorView {

    /// Coordinator for the terminal emulator view.
    final class Coordinator: NSObject, LocalProcessTerminalViewDelegate {

        /// URL
        @State
        private var url: URL

        /// Initializer
        /// 
        /// - Parameter url: URL
        public init(url: URL) {
            self._url = .init(wrappedValue: url)
            super.init()
        }

        /// Host current directory update
        /// 
        /// - Parameter source: terminal view
        /// - Parameter directory: directory
        public func hostCurrentDirectoryUpdate(source: TerminalView, directory: String?) {}

        /// Size changed
        /// 
        /// - Parameter source: terminal view
        /// - Parameter newCols: new columns
        /// - Parameter newRows: new rows
        public func sizeChanged(source: LocalProcessTerminalView, newCols: Int, newRows: Int) {}

        /// Set terminal title
        /// 
        /// - Parameter source: terminal view
        /// - Parameter title: title
        public func setTerminalTitle(source: LocalProcessTerminalView, title: String) {}

        /// Process terminated
        /// 
        /// - Parameter source: terminal view
        /// - Parameter exitCode: exit code
        public func processTerminated(source: TerminalView, exitCode: Int32?) {
            guard let exitCode = exitCode else {
                return
            }
            source.feed(text: "Exit code: \(exitCode)\n\r\n")
            source.feed(text: "To open a new session close and reopen the terminal drawer")
            TerminalEmulatorView.lastTerminal[url.path] = nil
        }
    }
}
