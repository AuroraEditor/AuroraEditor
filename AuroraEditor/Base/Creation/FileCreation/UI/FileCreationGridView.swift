//
//  FileCreationGridView.swift
//  AuroraEditor
//
//  Created by Nanashi Li on 2022/09/01.
//  Copyright © 2022 Aurora Company. All rights reserved.
//

import SwiftUI

struct FileCreationGridView: View {

    private var languageItems = [
        FileSelectionItem(languageName: "Java",
                          langaugeIcon: "scale.3d"),
        FileSelectionItem(languageName: "C++",
                          langaugeIcon: "scale.3d"),
        FileSelectionItem(languageName: "Kotlin",
                          langaugeIcon: "scale.3d"),
        FileSelectionItem(languageName: "Carbon",
                          langaugeIcon: "scale.3d"),
        FileSelectionItem(languageName: "C#",
                          langaugeIcon: "scale.3d"),
        FileSelectionItem(languageName: "Swift",
                          langaugeIcon: "scale.3d"),
        FileSelectionItem(languageName: "Rust",
                          langaugeIcon: "scale.3d")
    ]

    private var gridItemLayout = [GridItem(.flexible()),
                                  GridItem(.flexible()),
                                  GridItem(.flexible()),
                                  GridItem(.flexible()),
                                  GridItem(.flexible())]

    var body: some View {
        ScrollView(.vertical) {
            Section {
                LazyVGrid(columns: gridItemLayout) {
                    ForEach(languageItems, id: \.self) { language in
                        VStack {
                            Image(systemName: language.langaugeIcon)
                                .padding(.bottom, 10)
                            Text(language.languageName)
                        }
                        .padding()
                    }
                }
            } header: {
                VStack {
                    HStack {
                        Text("Source Files")
                            .font(.system(size: 12))
                            .foregroundColor(.secondary)
                            .fontWeight(.medium)
                            .padding(5)

                        Spacer()
                    }

                    Divider()
                        .padding(.vertical, -8)
                }
            }
        }
        .border(.gray.opacity(0.3))
    }
}

struct FileCreationGridView_Previews: PreviewProvider {
    static var previews: some View {
        FileCreationGridView()
    }
}
