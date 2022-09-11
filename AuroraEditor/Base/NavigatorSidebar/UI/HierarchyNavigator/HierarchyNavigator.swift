//
//  HierarchyNavigator.swift
//  AuroraEditor
//
//  Created by TAY KAI QUAN on 11/9/22.
//  Copyright © 2022 Aurora Company. All rights reserved.
//

import SwiftUI

struct HierarchyNavigator: View {
    @ObservedObject
    var workspace: WorkspaceDocument

    @State
    private var selectedSection: Int = 0

    init(workspace: WorkspaceDocument) {
        self.workspace = workspace
    }

    var body: some View {
        VStack {
            SegmentedControl($selectedSection,
                             options: ["Tabs", "Hierarchal", "Flat"],
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
                TabHierarchyView(workspace: workspace)
            }

            if selectedSection == 1 {
                // TODO: File Hierarchy View
                Text("File Hierarchy View")
            }

            if selectedSection == 2 {
                // TODO: Flat View
                Text("Flat View")
            }
        }
    }
}
