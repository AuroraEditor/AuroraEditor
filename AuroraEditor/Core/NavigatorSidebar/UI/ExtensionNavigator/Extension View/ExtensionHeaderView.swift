//
//  ExtensionHeaderView.swift
//  Aurora Editor
//
//  Created by Nanashi Li on 2022/11/10.
//  Copyright © 2023 Aurora Company. All rights reserved.
//

import SwiftUI

/// Extension header view.
struct ExtensionHeaderView: View {

    /// The extension info.
    @State
    var extensionInfo: Plugin

    /// The view body.
    var body: some View {
        VStack {
            HStack(alignment: .top) {
                AsyncImage(url: URL(string: "\(extensionInfo.extensionImage)")) { phase in
                    if let image = phase.image {
                        image
                            .resizable()
                            .scaledToFit()
                            .frame(width: 130, height: 130)
                            .clipShape(
                                RoundedRectangle(
                                    cornerRadius: 28
                                )
                            )
                            .accessibilityHidden(true)
                    } else if phase.error != nil {
                        Image(systemName: "lasso")
                            .frame(width: 130, height: 130)
                            .background(.blue)
                            .clipShape(
                                RoundedRectangle(
                                    cornerRadius: 28
                                )
                            )
                            .accessibilityHidden(true)
                    } else {
                        Image(systemName: "lasso")
                            .frame(width: 130, height: 130)
                            .background(.blue)
                            .clipShape(
                                RoundedRectangle(
                                    cornerRadius: 28
                                )
                            )
                            .accessibilityHidden(true)
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
                    .clipShape(
                        RoundedRectangle(
                            cornerRadius: 24
                        )
                    )
                }
                .padding(.leading, 34)
            }
        }
    }
}
