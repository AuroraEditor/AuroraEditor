//
//  FileCreationNamingView.swift
//  AuroraEditor
//
//  Created by Nanashi Li on 2022/08/30.
//  Copyright © 2022 Aurora Company. All rights reserved.
//

import SwiftUI

struct FileCreationNamingView: View {

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

                } label: {
                     Text("Cancel")
                }

                Button {

                } label: {
                     Text("Create")
                }
                .buttonStyle(.borderedProminent)
            }
            .padding(.vertical, 5)
        }
        .frame(width: 307, height: 95)
        .padding(15)
    }
}

struct FileCreationNamingView_Previews: PreviewProvider {
    static var previews: some View {
        FileCreationNamingView()
    }
}
