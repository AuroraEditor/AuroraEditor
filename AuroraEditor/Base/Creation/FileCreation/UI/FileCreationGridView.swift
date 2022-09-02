//
//  FileCreationGridView.swift
//  AuroraEditor
//
//  Created by Nanashi Li on 2022/09/01.
//  Copyright © 2022 Aurora Company. All rights reserved.
//

import SwiftUI

struct FileCreationGridView: View {

    @StateObject
    private var creationSheetModel: FileCreationModel = .shared

    private var gridItemLayout = [GridItem(.flexible()),
                                  GridItem(.flexible()),
                                  GridItem(.flexible()),
                                  GridItem(.flexible()),
                                  GridItem(.flexible())]

    var body: some View {
        ScrollView(.vertical) {
            Section {
                LazyVGrid(columns: gridItemLayout) {
                    ForEach(creationSheetModel.languageItems, id: \.self) { language in
                        VStack {
                            Image(language.langaugeIcon)
                                .padding(.bottom, 10)

                            Text(language.languageName)
                                .multilineTextAlignment(.center)
                                .lineLimit(1)
                                .font(.system(size: 11))
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
