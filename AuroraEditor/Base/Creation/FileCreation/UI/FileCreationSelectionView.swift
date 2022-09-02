//
//  FileCreationSelectionView.swift
//  AuroraEditor
//
//  Created by Nanashi Li on 2022/08/30.
//  Copyright © 2022 Aurora Company. All rights reserved.
//

import SwiftUI

struct FileCreationSelectionView: View {

    @ObservedObject
    private var editorSheetModel: EditorSheetViewsModel = .shared

    @StateObject
    private var creationSheetModel: FileCreationModel = .shared

    @State
    var isProjectCreation: Bool = false

    private var gridItemLayout = [GridItem(.flexible()),
                                  GridItem(.flexible()),
                                  GridItem(.flexible()),
                                  GridItem(.flexible()),
                                  GridItem(.flexible())]

    var body: some View {
        VStack(alignment: .leading) {
            Text("Choose a template for your new file:")
                .font(.system(size: 12))
                .padding(.top, -10)

            ScrollView(.vertical) {
                Section {
                    LazyVGrid(columns: gridItemLayout) {
                        ForEach(creationSheetModel.languageItems, id: \.self) { language in
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
                    }
                    Divider()
                        .padding(.vertical, -8)
                }

                Section {
                    LazyVGrid(columns: gridItemLayout) {
                        ForEach(creationSheetModel.languageItems, id: \.self) { language in
                            VStack {
                                Image(systemName: language.langaugeIcon)
                                    .padding(.bottom, 10)
                                Text(language.languageName)
                            }
                            .padding()
                        }
                    }
                } header: {
                    Divider()
                        .padding(.bottom, -15)
                    VStack {
                        HStack {
                            Text("Project Type")
                                .font(.system(size: 12))
                                .foregroundColor(.secondary)
                                .fontWeight(.medium)
                                .padding(5)
                                .padding(.top, -8)

                            Spacer()
                        }
                    }
                    Divider()
                        .padding(.vertical, -8)
                } footer: {
                    Divider()
                }
            }
            .border(.gray.opacity(0.3))

            HStack {
                Button {
                    editorSheetModel.showFileCreationSheet.toggle()
                } label: {
                    Text("Cancel")
                        .padding()
                        .foregroundColor(.primary)
                }

                Spacer()

                Button {

                } label: {
                    Text("Next")
                        .padding(10)
                        .padding()
                        .foregroundColor(.white)
                }
                .buttonStyle(.borderedProminent)
            }
        }
        .frame(width: 550)
        .padding()
    }
}

struct FileCreationSelectionView_Previews: PreviewProvider {
    static var previews: some View {
        FileCreationSelectionView()
    }
}
