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

    private let inputWidth: Double = 150

    @StateObject
    private var prefs: AppPreferencesModel = .shared

    public init() {}

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

    private var shellSelector: some View {
        HStack(alignment: .top) {
            Text("settings.terminal.shell")

            Spacer()

            VStack(alignment: .trailing) {
                Picker("", selection: $prefs.preferences.terminal.shell) {
                    Text("settings.terminal.shell.system")
                        .tag(AppPreferences.TerminalShell.system)
                    Divider()
                    Text("ZSH")
                        .tag(AppPreferences.TerminalShell.zsh)
                    Text("Bash")
                        .tag(AppPreferences.TerminalShell.bash)
                }
                .labelsHidden()
                .frame(width: inputWidth)

                HStack {
                    Toggle("settings.terminal.options", isOn: $prefs.preferences.terminal.optionAsMeta)
                }
            }
        }
    }

    @ViewBuilder
    private var fontSelector: some View {
        HStack {
            Text("settings.global.font")
            Spacer()
            Picker("", selection: $prefs.preferences.terminal.font.customFont) {
                Text("settings.global.font.system")
                    .tag(false)
                Text("settings.global.font.custom")
                    .tag(true)
            }
            .labelsHidden()
            .frame(width: inputWidth)
            if prefs.preferences.terminal.font.customFont {
                FontPicker(
                    "\(prefs.preferences.terminal.font.name) \(prefs.preferences.terminal.font.size)",
                    name: $prefs.preferences.terminal.font.name, size: $prefs.preferences.terminal.font.size
                )
            }
        }
    }

    private var cursorSelector: some View {
        HStack(alignment: .top) {
            Text("Cursor")
            Spacer()
            VStack(alignment: .trailing) {
                Picker("", selection: $prefs.preferences.terminal.cursorStyle) {
                    ForEach(AppPreferences.TerminalCursorStyle.allCases) { style in
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
