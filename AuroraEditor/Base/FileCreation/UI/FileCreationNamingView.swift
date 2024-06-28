//
//  FileCreationNamingView.swift
//  Aurora Editor
//
//  Created by Nanashi Li on 2022/08/30.
//  Copyright © 2023 Aurora Company. All rights reserved.
//

import SwiftUI
import OSLog

/// File creation naming view
struct FileCreationNamingView: View {
    /// Presentation mode
    @Environment(\.presentationMode)
    var presentationMode

    /// File creation model
    @ObservedObject
    private var creationSheetModel: FileCreationModel = .shared

    /// Workspace
    @State
    var workspace: WorkspaceDocument?

    /// File name
    @State
    var fileName: String = ""

    /// Tags
    @State
    var tags: String = ""

    /// Logger
    let logger = Logger(subsystem: "com.auroraeditor", category: "File creation naming view")

    /// The view body
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
                    guard let workspace = workspace else { return }
                    creationSheetModel.createLanguageFile(workspace: workspace,
                                                          fileName: fileName) { completion in
                        switch completion {
                        case .success:
                            presentationMode.wrappedValue.dismiss()
                            workspace.newFileModel.showFileCreationSheet.toggle()
                        case .failure(let failure):
                            self.logger.fault("\(failure)")
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
