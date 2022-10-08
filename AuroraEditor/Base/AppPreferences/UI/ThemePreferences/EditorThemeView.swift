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
        // TODO: Get editor colour customisation working again
        Spacer()
    }
}

private struct HighlightThemeView_Previews: PreviewProvider {
    static var previews: some View {
        HighlightThemeView()
    }
}
