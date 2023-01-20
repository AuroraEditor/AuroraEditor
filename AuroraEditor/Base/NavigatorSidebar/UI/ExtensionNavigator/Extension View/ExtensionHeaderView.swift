//
//  ExtensionHeaderView.swift
//  Aurora Editor
//
//  Created by Nanashi Li on 2022/11/10.
//  Copyright © 2023 Aurora Company. All rights reserved.
//

import SwiftUI

struct ExtensionHeaderView: View {

    @State
    var extensionInfo: Plugin

    var body: some View {
        VStack {
            HStack(alignment: .top) {
                AsyncImage(url: URL(string: "\(extensionInfo.extensionImage)")) { phase in
                    if let image = phase.image {
                        image
                            .resizable()
                            .scaledToFit()
                            .frame(width: 130, height: 130)
                            .cornerRadius(28)
                    } else if phase.error != nil {
                        Image(systemName: "lasso")
                            .frame(width: 130, height: 130)
                            .background(.blue)
                            .cornerRadius(28)
                    } else {
                        Image(systemName: "lasso")
                            .frame(width: 130, height: 130)
                            .background(.blue)
                            .cornerRadius(28)
                    }
                }

                VStack(alignment: .leading) {
                    Text(extensionInfo.extensionName)
                        .font(.largeTitle)
                        .fontWeight(.medium)

                    Text(extensionInfo.category.capitalizingFirstLetter())
                        .font(.title3)
                        .foregroundColor(.secondary)
                        .padding(.bottom, 34)

                    Button {
                        // TODO: Add install extension function
                    } label: {
                        Text("Get Extension")
                            .font(.title3)
                            .padding()
                    }
                    .frame(width: 170, height: 38)
                    .buttonStyle(.plain)
                    .background(Color(nsColor: NSColor(.accentColor)))
                    .cornerRadius(24)
                }
                .padding(.leading, 34)
            }
        }
    }
}
