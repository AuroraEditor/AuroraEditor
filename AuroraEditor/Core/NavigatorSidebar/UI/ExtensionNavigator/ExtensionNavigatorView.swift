//
//  ExtensionNavigator.swift
//  Aurora Editor
//
//  Created by Pavel Kasila on 6.04.22.
//  Copyright © 2023 Aurora Company. All rights reserved.
//

import SwiftUI
import Combine

/// Extension navigator data.
struct ExtensionNavigator: View {

    /// Workspace document
    @EnvironmentObject
    var workspace: WorkspaceDocument

    /// Extension navigator data
    @ObservedObject
    var data: ExtensionNavigatorData

    /// Show the navigator
    @State
    var showing = false

    /// Selected section
    @State
    private var selectedSection: Int = 1

    /// The view body.
    var body: some View {
        VStack {
            SegmentedControl($selectedSection,
                             options: ["Installed", "Explore"],
                             prominent: true)
            .frame(maxWidth: .infinity)
            .frame(height: 27)
            .padding(.horizontal, 8)
            .padding(.bottom, 2)
            .padding(.top, 1)
            .overlay(alignment: .bottom) {
                Divider()
            }

            if selectedSection == 0 {
                VStack(alignment: .center) {
                    HStack {
                        Spacer()
                        Text("No installed Extensions")
                        Spacer()
                    }
                }
                .frame(maxHeight: .infinity)
            }

            // https://github.com/AuroraEditor/AuroraEditor/issues/315
            ExploreExtensionsView(document: workspace)
                .opacity(selectedSection != 1 ? 0 : 1)
        }
    }
}
