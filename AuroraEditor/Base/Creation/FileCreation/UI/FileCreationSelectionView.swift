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

    var body: some View {
        VStack(alignment: .leading) {
            Text("Choose a template for your new file:")
                .font(.system(size: 12))
                .padding(.top, -10)

            if isProjectCreation {
                ProjectCreationGridView()
            } else {
                FileCreationGridView()
            }

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
