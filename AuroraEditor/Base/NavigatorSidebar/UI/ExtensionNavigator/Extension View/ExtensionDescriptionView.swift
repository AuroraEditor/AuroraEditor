//
//  ExtensionDescriptionView.swift
//  Aurora Editor
//
//  Created by Nanashi Li on 2022/11/10.
//  Copyright © 2023 Aurora Company. All rights reserved.
//

import SwiftUI

/// Extension description view.
struct ExtensionDescriptionView: View {

    /// Open URL
    @Environment(\.openURL)
    var githubRepo

    /// Open URL
    @Environment(\.openURL)
    var githubIssues

    /// The extension info.
    @State
    var extensionInfo: Plugin

    /// The view body.
    var body: some View {
        HStack(alignment: .top) {
            Text("\(extensionInfo.extensionDescription)")
                .font(.system(size: 12))

            Spacer()

            VStack(alignment: .trailing) {
                Text(extensionInfo.creator.name)
                    .foregroundColor(.accentColor)

                Button {
                    // TODO: Open github repo
                } label: {
                    HStack {
                        Text("GitHub Repo")
                            .foregroundColor(.secondary)
                        Image("github")
                            .resizable()
                            .frame(width: 22, height: 22)
                    }
                }
                .buttonStyle(.plain)

                Button {
                    // TODO: Open github repo issues
                } label: {
                    HStack {
                        Text("Issues")
                            .foregroundColor(.secondary)
                        Image("github")
                            .resizable()
                            .frame(width: 22, height: 22)
                    }
                    .padding(.top, -5)
                }
                .buttonStyle(.plain)
            }
        }
    }
}
