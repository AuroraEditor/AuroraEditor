//
//  WebProjectView.swift
//  AuroraEditor
//
//  Created by Nanashi Li on 2022/09/01.
//  Copyright © 2022 Aurora Company. All rights reserved.
//

import SwiftUI

struct WebProjectView: View {

    @ObservedObject
    private var creationSheetModel: ProjectCreationModel = .shared

    private var gridItemLayout: [GridItem] = Array(repeating: .init(.flexible()),
                                                   count: 5)

    @State
    var selectedItem: ProjectSelectionItem = ProjectSelectionItem(languageName: "Flutter",
                                                                  langaugeIcon: "fluttersvg")

    var body: some View {
        VStack {
            ScrollView(.vertical) {
                LazyVGrid(columns: gridItemLayout) {
                    ForEach(creationSheetModel.webProjects, id: \.self) { project in
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

struct WebProjectView_Previews: PreviewProvider {
    static var previews: some View {
        WebProjectView()
    }
}
