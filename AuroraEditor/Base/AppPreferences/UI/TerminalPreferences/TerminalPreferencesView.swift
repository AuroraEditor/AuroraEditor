//
//  TerminalPreferencesView.swift
//  Aurora Editor
//
//  Created by Lukas Pistrol on 02.04.22.
//  Copyright © 2023 Aurora Company. All rights reserved.
//

import SwiftUI

/// A view that implements the `Terminal` preference section
public struct TerminalPreferencesView: View {
    /// The input width
    private let inputWidth: Double = 150

    /// The preferences model
    @StateObject
    private var prefs: AppPreferencesModel = .shared

    /// Initializes the terminal preferences view
    public init() {}

    /// The view body
    public var body: some View {
        PreferencesContent {
            GroupBox {
                shellSelector
                    .padding(.top, 5)
                    .padding(.horizontal)
                Divider()
                fontSelector
                    .padding(.horizontal)
                    .padding(.bottom, 5)
                Divider()
                cursorSelector
                    .padding(.horizontal)
                    .padding(.bottom, 5)
            }
        }
    }

    /// The shell selector
    private var shellSelector: some View {
        HStack(alignment: .top) {
            Text("settings.terminal.shell")

            Spacer()

            VStack(alignment: .trailing) {
                Picker("", selection: $prefs.preferences.terminal.shell) {
                    Text("settings.terminal.shell.system")
                        .tag(TerminalShell.system)
                    Divider()
                    Text("ZSH")
                        .tag(TerminalShell.zsh)
                    Text("Bash")
                        .tag(TerminalShell.bash)
                }
                .labelsHidden()
                .frame(width: inputWidth)

                HStack {
                    Toggle("settings.terminal.options", isOn: $prefs.preferences.terminal.optionAsMeta)
                }
            }
        }
    }

    /// The font selector
    @ViewBuilder
    private var fontSelector: some View {
        HStack {
            Text("settings.global.font")
            Spacer()
            Picker("", selection: $prefs.preferences.terminal.customTerminalFont) {
                Text("settings.global.font.system")
                    .tag(false)
                Text("settings.global.font.custom")
                    .tag(true)
            }
            .labelsHidden()
            .frame(width: inputWidth)
            if prefs.preferences.terminal.customTerminalFont {
                FontPicker(
                    "\(prefs.preferences.terminal.terminalFontName) \(prefs.preferences.terminal.terminalFontSize)",
                    name: $prefs.preferences.terminal.terminalFontName,
                    size: $prefs.preferences.terminal.terminalFontSize
                )
            }
        }
    }

    /// The cursor selector
    private var cursorSelector: some View {
        HStack(alignment: .top) {
            Text("Cursor")
            Spacer()
            VStack(alignment: .trailing) {
                Picker("", selection: $prefs.preferences.terminal.cursorStyle) {
                    ForEach(TerminalCursorStyle.allCases) { style in
                        Text(style.rawValue.capitalized)
                            .tag(style)
                    }
                }
                .pickerStyle(.radioGroup)
                Spacer()
                HStack {
                    Toggle("Blink cursor", isOn: $prefs.preferences.terminal.blinkCursor)
                }
            }
        }
    }
}

struct TerminalPreferencesView_Previews: PreviewProvider {
    static var previews: some View {
        TerminalPreferencesView()
    }
}
