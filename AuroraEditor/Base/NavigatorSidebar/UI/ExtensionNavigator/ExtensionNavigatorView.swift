//
//  ExtensionNavigator.swift
//  Aurora Editor
//
//  Created by Pavel Kasila on 6.04.22.
//  Copyright © 2023 Aurora Company. All rights reserved.
//

import SwiftUI
import Combine

struct ExtensionNavigator: View {
    @EnvironmentObject
    var workspace: WorkspaceDocument

    @ObservedObject
    var data: ExtensionNavigatorData

    @State
    var showing = false

    @State
    private var selectedSection: Int = 1

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
