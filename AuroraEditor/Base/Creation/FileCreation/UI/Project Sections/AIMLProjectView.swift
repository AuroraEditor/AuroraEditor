//
//  AIMLProjectView.swift
//  AuroraEditor
//
//  Created by Nanashi Li on 2022/09/01.
//  Copyright © 2022 Aurora Company. All rights reserved.
//

import SwiftUI

struct AIMLProjectView: View {

    @ObservedObject
    private var creationSheetModel: ProjectCreationModel = .shared

    private var gridItemLayout: [GridItem] = Array(repeating: .init(.flexible()),
                                                   count: 5)

    @State
    var selectedItem: ProjectSelectionItem = ProjectSelectionItem(languageName: "Python",
                                                                  langaugeIcon: "python")

    var body: some View {
        VStack {
            ScrollView(.vertical) {
                LazyVGrid(columns: gridItemLayout) {
                    ForEach(creationSheetModel.aiMLProjects, id: \.self) { project in
                        ProjectGridColumn(item: project,
                                          selectedItem: $creationSheetModel.selectedProjectItem)
                        .padding()
                    }
                }
            }
            .frame(maxWidth: .infinity)
            .onAppear {
                creationSheetModel.selectedProjectItem = selectedItem
            }
        }
    }
}

struct AIMLProjectView_Previews: PreviewProvider {
    static var previews: some View {
        AIMLProjectView()
    }
}
