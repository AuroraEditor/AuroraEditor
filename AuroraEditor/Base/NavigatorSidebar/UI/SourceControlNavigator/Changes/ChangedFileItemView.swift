//
//  ChangedFileItemView.swift
//  Aurora Editor
//
//  Created by Nanashi Li on 2022/05/20.
//  Copyright © 2023 Aurora Company. All rights reserved.
//

import SwiftUI

/// A view for a changed file item.
struct ChangedFileItemView: View {

    /// The changed file.
    @State
    var changedFile: FileItem

    /// The selection.
    @Binding
    var selection: FileItem.ID?

    /// The workspace.
    @State
    var workspace: WorkspaceDocument

    /// The view body.
    var body: some View {
        HStack {
            Image(systemName: changedFile.systemImage)
                .frame(width: 11, height: 11)
                .foregroundColor(selection == changedFile.id ? .white : changedFile.iconColor)

            Text(changedFile.fileName)
                .font(.system(size: 11))
                .foregroundColor(selection == changedFile.id ? .white : .secondary)

            Text(changedFile.changeTypeValue)
                .font(.system(size: 11))
                .foregroundColor(selection == changedFile.id ? .white : .secondary)
                .frame(maxWidth: .infinity, alignment: .trailing)
        }
        .padding(.leading, 15)
        .onTapGesture {
            workspace.openTab(item: changedFile)
        }
    }
}
