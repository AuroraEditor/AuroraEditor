//
//  FileCreationSelectionView.swift
//  Aurora Editor
//
//  Created by Nanashi Li on 2022/08/30.
//  Copyright © 2023 Aurora Company. All rights reserved.
//

import SwiftUI

struct FileCreationSelectionView: View {

    @Environment(\.presentationMode)
    var presentationMode

    @StateObject
    private var creationSheetModel: FileCreationModel = .shared

    @State
    var workspace: WorkspaceDocument?

    @State
    var showFileNamingSheet: Bool = false

    var body: some View {
        VStack(alignment: .leading) {
            Text("Choose a template for your new file:")
                .font(.system(size: 12))
                .padding(.top, -10)

            FileCreationGridView()

            HStack {
                Button {
                    presentationMode.wrappedValue.dismiss()
                } label: {
                    Text("Cancel")
                        .padding()
                        .foregroundColor(.primary)
                }

                Spacer()

                Button {
                    showFileNamingSheet = true
                } label: {
                    Text("Next")
                        .padding(10)
                        .padding()
                        .foregroundColor(.white)
                }
                .buttonStyle(.borderedProminent)
                .sheet(isPresented: $showFileNamingSheet) {
                    FileCreationNamingView(workspace: workspace,
                                           // swiftlint:disable:next line_length
                                           fileName: "untitled.\(creationSheetModel.selectedLanguageItem.languageExtension)")
                }
            }
        }
        .frame(width: 697, height: 487)
        .padding()
    }
}
