//
//  FileCreationNamingView.swift
//  AuroraEditor
//
//  Created by Nanashi Li on 2022/08/30.
//  Copyright © 2022 Aurora Company. All rights reserved.
//

import SwiftUI

struct FileCreationNamingView: View {

    @Environment(\.presentationMode)
    var presentationMode

    @ObservedObject
    private var creationSheetModel: FileCreationModel = .shared

    @State
    var workspace: WorkspaceDocument?

    @State
    var fileName: String = ""

    @State
    var tags: String = ""

    var body: some View {
        VStack(alignment: .trailing) {
            HStack {
                Text("Save As:")
                    .font(.system(size: 11))
                    .foregroundColor(.secondary)

                TextField("File Name", text: $fileName)
                    .textFieldStyle(.roundedBorder)
                    .frame(width: 250)
            }

            HStack {
                Text("Tags:")
                    .font(.system(size: 11))
                    .foregroundColor(.secondary)

                TextField("", text: $tags)
                    .textFieldStyle(.roundedBorder)
                    .frame(width: 250)
            }

            Divider()
                .padding(.horizontal, -15)

            HStack {
                Spacer()
                Button {
                    presentationMode.wrappedValue.dismiss()
                } label: {
                     Text("Cancel")
                        .foregroundColor(.primary)
                }

                Button {
                    guard let workspaceURL = workspace?.fileSystemClient?.folderURL else {
                        return
                    }
                    creationSheetModel.createLanguageFile(directoryURL: workspaceURL,
                                                          fileName: fileName) { completion in
                        switch completion {
                        case .success:
                            presentationMode.wrappedValue.dismiss()
                            workspace?.newFileModel.showFileCreationSheet.toggle()
                        case .failure(let failure):
                            Log.error(failure)
                        }
                    }
                } label: {
                     Text("Create")
                        .foregroundColor(.white)
                }
                .buttonStyle(.borderedProminent)
            }
        }
        .frame(width: 307, height: 90)
        .padding(15)
    }
}
