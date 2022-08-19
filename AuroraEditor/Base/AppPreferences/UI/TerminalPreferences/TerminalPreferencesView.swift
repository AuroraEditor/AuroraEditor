//
//  TerminalPreferencesView.swift
//  AuroraEditorModules/AppPreferences
//
//  Created by Lukas Pistrol on 02.04.22.
//

import SwiftUI
import Preferences

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
            }
        }
    }

    private var shellSelector: some View {
        HStack(alignment: .top) {
            Text("Shell")

            Spacer()

            VStack(alignment: .trailing) {
                Picker("Shell:", selection: $prefs.preferences.terminal.shell) {
                    Text("System Default")
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
                    Toggle("Use \"Option\" key as \"Meta\"", isOn: $prefs.preferences.terminal.optionAsMeta)
                }
            }
        }
    }

    @ViewBuilder
    private var fontSelector: some View {
        HStack {
            Text("Font")
            Spacer()
            Picker("Font:", selection: $prefs.preferences.terminal.font.customFont) {
                Text("System Font")
                    .tag(false)
                Text("Custom")
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
}

struct TerminalPreferencesView_Previews: PreviewProvider {
    static var previews: some View {
        TerminalPreferencesView()
    }
}
