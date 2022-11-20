//
//  ExtensionInformationView.swift
//  AuroraEditor
//
//  Created by Nanashi Li on 2022/11/10.
//  Copyright © 2022 Aurora Company. All rights reserved.
//

import SwiftUI

struct ExtensionInformationView: View {

    @State
    var extensionInfo: Plugin

    var body: some View {
        VStack(alignment: .leading) {
            Text("Information")
                .font(.title)
                .fontWeight(.medium)

            HStack(spacing: 30) {
                VStack(alignment: .leading) {
                    Text("Developer")
                        .foregroundColor(.secondary)

                    Text(extensionInfo.creator.name)
                        .foregroundColor(.primary)
                }
                .frame(width: 190, alignment: .leading)

                VStack(alignment: .leading) {
                    Text("Size")
                        .foregroundColor(.secondary)

                    Text("11.4MB")
                        .foregroundColor(.primary)
                }
                .frame(width: 190, alignment: .leading)

                VStack(alignment: .leading) {
                    Text("Category")
                        .foregroundColor(.secondary)

                    Text(extensionInfo.category.capitalizingFirstLetter())
                        .foregroundColor(.primary)
                }
                .frame(width: 190, alignment: .leading)

                VStack(alignment: .leading) {
                    Text("Compatibility")
                        .foregroundColor(.secondary)

                    Text("Universal")
                        .foregroundColor(.primary)
                }
                .frame(width: 190, alignment: .leading)

                VStack(alignment: .leading) {
                    Text("Languages")
                        .foregroundColor(.secondary)

                    Text("English")
                        .foregroundColor(.primary)
                }
                .frame(width: 190, alignment: .leading)
            }
            .padding(.top, 5)

            HStack(spacing: 30) {
                VStack(alignment: .leading) {
                    Text("Copyright")
                        .foregroundColor(.secondary)

                    Text("© \(extensionInfo.creator.name)")
                        .foregroundColor(.primary)
                }
                .frame(width: 190, alignment: .leading)
            }
            .padding(.top)

            HStack(spacing: 30) {
                VStack(alignment: .leading) {
                    Divider()
                    Label("Privacy Policy", systemImage: "doc.text")
                        .foregroundColor(.accentColor)
                }
                .frame(width: 190, alignment: .leading)
            }
            .padding(.vertical)
        }
    }
}
