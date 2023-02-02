//
//  PreferenceSourceControlView.swift
//  Aurora Editor
//
//  Created by Nanshi Li on 2022/04/01.
//  Copyright © 2023 Aurora Company. All rights reserved.
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
            Text("settings.source.control.tab.general")
                .fontWeight(.bold)
                .padding(.horizontal)
            SourceControlGeneralView(isChecked: true, branchName: "main")
                .padding(.bottom)

            Text("settings.source.control.tab.git")
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
