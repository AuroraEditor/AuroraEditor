//
//  TerminalThemeView.swift
//  Aurora Editor
//
//  Created by Lukas Pistrol on 31.03.22.
//  Copyright © 2023 Aurora Company. All rights reserved.
//

import SwiftUI

struct TerminalThemeView: View {
    @StateObject
    private var prefs: AppPreferencesModel = .shared

    @StateObject
    private var themeModel: ThemeModel = .shared

    init() {}

    var body: some View {
        ZStack(alignment: .topLeading) {
            EffectView(.contentBackground)
            if themeModel.selectedTheme == nil {
                Text("settings.theme.selection")
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
            } else {
                ScrollView(.vertical, showsIndicators: true) {
                    VStack(alignment: .leading, spacing: 15) {
                        topToggles
                        colorSelector
                        ansiColorSelector
                    }
                    .padding(10)
                }
            }
        }
    }

    private var topToggles: some View {
        VStack(alignment: .leading) {
            Toggle("settings.theme.terminal.dark", isOn: $prefs.preferences.terminal.darkAppearance)
        }
    }

    private var colorSelector: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("settings.theme.terminal.background.text")
                .font(.system(size: 13, weight: .semibold))
                .foregroundColor(.secondary)
                .padding(.bottom, 10)
            HStack(alignment: .top, spacing: 0) {
                if let selectedTheme = themeModel.selectedTheme,
                   let index = themeModel.themes.firstIndex(of: selectedTheme) {
                    VStack(alignment: .leading, spacing: 10) {
                        PreferencesColorPicker($themeModel.themes[index].terminal.text.swiftColor,
                                               label: "settings.theme.terminal.text")
                        PreferencesColorPicker($themeModel.themes[index].terminal.boldText.swiftColor,
                                               label: "settings.theme.terminal.text.bold")
                        PreferencesColorPicker($themeModel.themes[index].terminal.cursor.swiftColor,
                                               label: "settings.theme.terminal.cursor")
                        PreferencesColorPicker($themeModel.themes[index].terminal.background.swiftColor,
                                               label: "settings.theme.terminal.background")
                        PreferencesColorPicker($themeModel.themes[index].terminal.selection.swiftColor,
                                               label: "settings.theme.terminal.selection")
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
        }
    }

    private var ansiColorSelector: some View {
        VStack(alignment: .leading, spacing: 5) {
            if let selectedTheme = themeModel.selectedTheme,
               let index = themeModel.themes.firstIndex(of: selectedTheme) {
                Text("settings.theme.terminal.ansi.colors")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(.secondary)
                    .padding(.bottom, 5)
                Text("settings.theme.terminal.ansi.colors.normal").padding(.leading, 4)
                HStack(spacing: 5) {
                    PreferencesColorPicker($themeModel.themes[index].terminal.black.swiftColor)
                    PreferencesColorPicker($themeModel.themes[index].terminal.red.swiftColor)
                    PreferencesColorPicker($themeModel.themes[index].terminal.green.swiftColor)
                    PreferencesColorPicker($themeModel.themes[index].terminal.yellow.swiftColor)
                }
                HStack(spacing: 5) {
                    PreferencesColorPicker($themeModel.themes[index].terminal.blue.swiftColor)
                    PreferencesColorPicker($themeModel.themes[index].terminal.magenta.swiftColor)
                    PreferencesColorPicker($themeModel.themes[index].terminal.cyan.swiftColor)
                    PreferencesColorPicker($themeModel.themes[index].terminal.white.swiftColor)
                }
                Text("settings.theme.terminal.ansi.colors.bright").padding(.leading, 4)
                HStack(spacing: 5) {
                    PreferencesColorPicker($themeModel.themes[index].terminal.brightBlack.swiftColor)
                    PreferencesColorPicker($themeModel.themes[index].terminal.brightRed.swiftColor)
                    PreferencesColorPicker($themeModel.themes[index].terminal.brightGreen.swiftColor)
                    PreferencesColorPicker($themeModel.themes[index].terminal.brightYellow.swiftColor)
                }
                HStack(spacing: 5) {
                    PreferencesColorPicker($themeModel.themes[index].terminal.brightBlue.swiftColor)
                    PreferencesColorPicker($themeModel.themes[index].terminal.brightMagenta.swiftColor)
                    PreferencesColorPicker($themeModel.themes[index].terminal.brightCyan.swiftColor)
                    PreferencesColorPicker($themeModel.themes[index].terminal.brightWhite.swiftColor)
                }
            }
        }
    }
}

private struct TerminalThemeView_Previews: PreviewProvider {
    static var previews: some View {
        TerminalThemeView()
            .preferredColorScheme(.dark)
    }
}
