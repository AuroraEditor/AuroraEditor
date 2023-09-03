//
//  TerminalEmulatorView+Coordinator.swift
//  Aurora Editor
//
//  Created by Lukas Pistrol on 24.03.22.
//  Copyright © 2023 Aurora Company. All rights reserved.
//
//  This file originates from CodeEdit, https://github.com/CodeEditApp/CodeEdit

import SwiftUI
import SwiftTerm

public extension TerminalEmulatorView {
    final class Coordinator: NSObject, LocalProcessTerminalViewDelegate {

        @State
        private var url: URL

        public init(url: URL) {
            self._url = .init(wrappedValue: url)
            super.init()
        }

        public func hostCurrentDirectoryUpdate(source: TerminalView, directory: String?) {}

        public func sizeChanged(source: LocalProcessTerminalView, newCols: Int, newRows: Int) {}

        public func setTerminalTitle(source: LocalProcessTerminalView, title: String) {}

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
