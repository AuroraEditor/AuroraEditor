//
//  PreferenceSourceControlView.swift
//  CodeEditModules/AppPreferences
//
//  Created by Nanshi Li on 2022/04/01.
//

import SwiftUI
import AuroraEditorUI

public struct PreferenceSourceControlView: View {

    public init() {}

    @ObservedObject
    private var prefs: AppPreferencesModel = .shared

    @State
    private var selectedSection: Int = 0

    public var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            VStack(spacing: 1) {
                PreferencesToolbar {
                    if prefs.sourceControlActive() {
                        SegmentedControl($selectedSection, options: ["General", "Git"])
                    } else {
                        SegmentedControl($selectedSection, options: ["General"])
                    }
                }
                if selectedSection == 0 {
                    SourceControlGeneralView(isChecked: true, branchName: "main")
                }
                if selectedSection == 1 {
                    SourceControlGitView()
                }
            }
            .padding(1)
            .background(Rectangle().foregroundColor(Color(NSColor.separatorColor)))
            .frame(width: 872)
            .padding()
        }
    }
}

struct PreferenceSourceControlView_Previews: PreviewProvider {
    static var previews: some View {
        PreferenceSourceControlView()
    }
}