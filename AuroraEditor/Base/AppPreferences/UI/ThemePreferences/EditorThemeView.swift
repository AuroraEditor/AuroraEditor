//
//  HighlightThemeView.swift
//  AuroraEditorModules/AppPreferences
//
//  Created by Lukas Pistrol on 31.03.22.
//

import SwiftUI

struct HighlightThemeView: View {

    @StateObject
    private var themeModel: ThemeModel = .shared

    @StateObject
    private var prefs: AppPreferencesModel = .shared

    var body: some View {
        ZStack {
            EffectView(.contentBackground)
            if themeModel.selectedTheme == nil {
                Text("Select a Theme")
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
            } else {
                ScrollView(.vertical, showsIndicators: true) {
                    VStack(alignment: .leading) {
                        Spacer().frame(height: 5)
                        GroupBox {
                            HStack {
                                VStack(alignment: .leading) {
                                    HStack {
                                        PreferencesColorPicker(.init(get: {
                                            themeModel.selectedTheme?.editor.text.swiftColor ?? .white
                                        }, set: { newColor in
                                            themeModel.selectedTheme?.editor.text.swiftColor = newColor
                                        }))
                                        Text("Text")
                                    }
                                    HStack {
                                        PreferencesColorPicker(.init(get: {
                                            themeModel.selectedTheme?.editor.insertionPoint.swiftColor ?? .white
                                        }, set: { newColor in
                                            themeModel.selectedTheme?.editor.insertionPoint.swiftColor = newColor
                                        }))
                                        Text("Cursor")
                                    }
                                    HStack {
                                        PreferencesColorPicker(.init(get: {
                                            themeModel.selectedTheme?.editor.invisibles.swiftColor ?? .white
                                        }, set: { newColor in
                                            themeModel.selectedTheme?.editor.invisibles.swiftColor = newColor
                                        }))
                                        Text("Invisibles")
                                    }
                                    HStack {
                                        PreferencesColorPicker(.init(get: {
                                            themeModel.selectedTheme?.editor.background.swiftColor ?? .white
                                        }, set: { newColor in
                                            themeModel.selectedTheme?.editor.background.swiftColor = newColor
                                        }))
                                        Text("Background")
                                    }
                                    HStack {
                                        PreferencesColorPicker(.init(get: {
                                            themeModel.selectedTheme?.editor.lineHighlight.swiftColor ?? .white
                                        }, set: { newColor in
                                            themeModel.selectedTheme?.editor.lineHighlight.swiftColor = newColor
                                        }))
                                        Text("Current Line")
                                    }
                                    HStack {
                                        PreferencesColorPicker(.init(get: {
                                            themeModel.selectedTheme?.editor.selection.swiftColor ?? .white
                                        }, set: { newColor in
                                            themeModel.selectedTheme?.editor.selection.swiftColor = newColor
                                        }))
                                        Text("Selection")
                                    }
                                }
                                Spacer()
                            }
                            .padding(.horizontal, 5)
                        }
                        .padding(.horizontal, 7)

                        ForEach((themeModel.selectedTheme ?? themeModel.themes.first!).editor.highlightTheme.settings,
                                id: \.scopes) { setting in
                            EditorThemeAttributeView(setting: setting)
                                .transition(.opacity)
                        }
                        Spacer().frame(height: 5)
                    }
                }
            }
        }
    }
}

private struct HighlightThemeView_Previews: PreviewProvider {
    static var previews: some View {
        HighlightThemeView()
    }
}
