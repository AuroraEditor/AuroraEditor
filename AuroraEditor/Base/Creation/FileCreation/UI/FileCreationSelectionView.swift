//
//  FileCreationSelectionView.swift
//  AuroraEditor
//
//  Created by Nanashi Li on 2022/08/30.
//  Copyright © 2022 Aurora Company. All rights reserved.
//

import SwiftUI

struct FileCreationSelectionView: View {

    @Environment(\.presentationMode)
    var presentationMode

    @StateObject
    private var creationSheetModel: FileCreationModel = .shared

    @StateObject
    private var projectCreationModel: ProjectCreationModel = .shared

    @State
    var workspace: WorkspaceDocument

    @State
    var isProjectCreation: Bool = false

    @State
    var showFileNamingSheet: Bool = false

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
                    presentationMode.wrappedValue.dismiss()
                } label: {
                    Text("Cancel")
                        .padding()
                        .foregroundColor(.primary)
                }

                Spacer()

                Button {
                    if isProjectCreation {
                        projectCreationModel.createAEProject(projectName: "test-react-project") { completion in
                            switch completion {
                            case .success:
                                presentationMode.wrappedValue.dismiss()
                            case .failure(let error):
                                Log.error(error)
                            }
                        }
                    } else {
                        showFileNamingSheet = true
                    }
                } label: {
                    Text("Next")
                        .padding(10)
                        .padding()
                        .foregroundColor(.white)
                }
                .buttonStyle(.borderedProminent)
                .sheet(isPresented: $showFileNamingSheet) {
                    if !isProjectCreation {
                        FileCreationNamingView(workspace: workspace,
                                               // swiftlint:disable:next line_length
                                               fileName: "untitled.\(creationSheetModel.selectedLanguageItem.languageExtension)")
                    }
                }
            }
        }
        .frame(width: 697, height: 487)
        .padding()
    }
}

struct FileCreationSelectionView_Previews: PreviewProvider {
    static var previews: some View {
        FileCreationSelectionView(workspace: WorkspaceDocument())
    }
}
