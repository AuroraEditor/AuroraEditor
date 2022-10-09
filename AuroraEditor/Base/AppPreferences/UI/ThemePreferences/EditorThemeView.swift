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
                            EditorThemeAttributeView(setting: setting)
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
