//
//  ProjectCreationGridView.swift
//  AuroraEditor
//
//  Created by Nanashi Li on 2022/09/01.
//  Copyright © 2022 Aurora Company. All rights reserved.
//

import SwiftUI

struct ProjectCreationGridView: View {

    @ObservedObject
    private var creationSheetModel: ProjectCreationModel = .shared

    private var gridItemLayout = [GridItem(.flexible()),
                                  GridItem(.flexible()),
                                  GridItem(.flexible()),
                                  GridItem(.flexible()),
                                  GridItem(.flexible())]

    var body: some View {
        VStack(alignment: .leading) {
            SegmentedControl($creationSheetModel.selectedSection,
                             options: ["Cross-platform", "Web", "AI/ML"],
                             prominent: true)
            .frame(height: 27)
            .padding(.horizontal, 8)
            .padding(.bottom, 2)
            .overlay(alignment: .bottom) {
                Divider()
            }

            if creationSheetModel.selectedSection == 0 {
                CrossPlatformProjectView()
            }

            if creationSheetModel.selectedSection == 1 {
                WebProjectView()
            }

            if creationSheetModel.selectedSection == 2 {
                AIMLProjectView()
            }
        }
        .border(Color(nsColor: NSColor.separatorColor))
    }
}

struct ProjectCreationGridView_Previews: PreviewProvider {
    static var previews: some View {
        ProjectCreationGridView()
    }
}
