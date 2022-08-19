//
//  PreferenceSourceControlView.swift
//  AuroraEditorModules/AppPreferences
//
//  Created by Nanshi Li on 2022/04/01.
//

import SwiftUI

public struct PreferenceSourceControlView: View {

    public init() {}

    @ObservedObject
    private var prefs: AppPreferencesModel = .shared

    @State
    private var selectedSection: Int = 0

    public var body: some View {
        PreferencesContent {
            Text("General")
                .fontWeight(.bold)
                .padding(.horizontal)
            SourceControlGeneralView(isChecked: true, branchName: "main")
                .padding(.bottom)

            Text("Git")
                .fontWeight(.bold)
                .padding(.horizontal)
            SourceControlGitView()
        }
    }
}

struct PreferenceSourceControlView_Previews: PreviewProvider {
    static var previews: some View {
        PreferenceSourceControlView()
    }
}
