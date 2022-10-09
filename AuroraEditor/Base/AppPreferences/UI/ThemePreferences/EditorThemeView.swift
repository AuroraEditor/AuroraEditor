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
                        ForEach((themeModel.selectedTheme ?? themeModel.themes.first!).editor.highlightTheme.settings,
                                id: \.scope) { setting in
                            GroupBox {
                                HStack {
                                    VStack(alignment: .leading) {
                                        // TODO: Allow horizontal overflow on this
                                        TextField("Scope Name", text: .init(get: { setting.scope }, set: { newScope in
                                            let selectedTheme = (themeModel.selectedTheme ?? themeModel.themes.first!)
                                                .editor.highlightTheme
                                            // get the index of the setting, and ensure that the scope that the user
                                            // is trying to change the name to is not preexisting
                                            guard let settingIndex = selectedTheme.settings.firstIndex(where: {
                                                $0.scope == setting.scope}),
                                                  selectedTheme.settings.contains(where: { $0.scope == newScope })
                                            else { return }

                                            selectedTheme.settings[settingIndex].scope = newScope

                                            // update the root
                                            selectedTheme.root = HighlightTheme
                                                .createTrie(settings: selectedTheme.settings)
                                        }))
                                        ForEach(setting.attributes, id: \.key) { attribute in
                                            if let attribute = attribute as? ColorThemeAttribute {
                                                PreferencesColorPicker(.constant(Color(nsColor: attribute.color)))
                                            }
                                        }
                                    }
                                    Spacer()
                                }
                                .padding(.horizontal, 5)
                            }
                            .padding(.horizontal, 7)
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
