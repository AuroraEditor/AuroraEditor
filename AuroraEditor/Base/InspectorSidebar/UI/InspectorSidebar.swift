//
//  InspectorSidebar.swift
//  Aurora Editor
//
//  Created by Austin Condiff on 3/21/22.
//  Copyright © 2023 Aurora Company. All rights reserved.
//
//  This file originates from CodeEdit, https://github.com/CodeEditApp/CodeEdit

import SwiftUI

// The main Inspector View that handles showing the different
// views that the inspector has like the file inspector, history and
// Quick Help.
struct InspectorSidebar: View {

    @Environment(\.controlActiveState)
    private var activeState

    @EnvironmentObject
    private var workspace: WorkspaceDocument

    @State
    private var selection: Int = 0

    let prefs: AppPreferencesModel

    var body: some View {
        VStack {
            if let item = workspace.selectionState.openFileItems.first(where: { file in
                file.tabID == workspace.selectionState.selectedId
            }) {
                if let codeFile = workspace.selectionState.openedCodeFiles[item] {
                    switch selection {
                    case 0:
                        FileInspectorView(workspaceURL: workspace.fileURL!,
                                          fileURL: codeFile.fileURL!.path)
                        .frame(maxWidth: .infinity)
                    case 1:
                        HistoryInspector(workspaceURL: workspace.fileURL!,
                                         fileURL: codeFile.fileURL!.path)
                    case 2:
                        QuickHelpInspector().padding(5)
                    default: EmptyView()
                    }
                }
            } else {
                NoSelectionView()
            }
        }
        .frame(
            minWidth: 250,
            idealWidth: 260,
            minHeight: 0,
            maxHeight: .infinity,
            alignment: .top
        )
        .isHidden(!prefs.preferences.general.keepInspectorSidebarOpen)
        .safeAreaInset(edge: .top) {
            InspectorSidebarToolbarTop(selection: $selection)
                .padding(.bottom, -8)
        }
        .background(
            EffectView(.windowBackground, blendingMode: .withinWindow)
        )
        .opacity(activeState == .inactive ? 0.45 : 1)
    }
}
