//
//  ChangedFileItemView.swift
//  AuroraEditor
//
//  Created by Nanashi Li on 2022/05/20.
//

import SwiftUI

struct ChangedFileItemView: View {

    @State
    var changedFile: ChangedFile

    @Binding
    var selection: ChangedFile.ID?

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
    }
}
