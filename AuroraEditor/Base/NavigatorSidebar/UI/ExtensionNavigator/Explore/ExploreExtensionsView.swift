//
//  ExploreExtensionsView.swift
//  Aurora Editor
//
//  Created by Nanashi Li on 2022/10/29.
//  Copyright © 2023 Aurora Company. All rights reserved.
//

import SwiftUI

struct ExploreExtensionsView: View {

    @StateObject
    private var extensionsModel: ExtensionInstallationViewModel = .init()

    var document: WorkspaceDocument

    var body: some View {
        VStack {
            switch extensionsModel.state {
            case .loading:
                VStack {
                    Text("Loading Extensions")
                        .font(.system(size: 16))
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            case .success:
                    if extensionsModel.extensions.isEmpty {
                        VStack {
                            Text("No Installed Extensions")
                                .font(.system(size: 16))
                                .foregroundColor(.secondary)
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                    } else {
                        List {
                            ForEach(extensionsModel.extensions, id: \.self) { plugin in
                                Button {
                                    document.openTab(item: plugin)
                                } label: {
                                    ExploreItemView(
                                        extensionData: plugin,
                                        extensionsModel: extensionsModel
                                    )
                                }
                                .tag(plugin.id)
                                .buttonStyle(.plain)
                            }
                        }
                    .listStyle(.sidebar)
                    .listRowInsets(.init())
                }

            case .error:
                VStack {
                    Text("Failed to fetch extensions.")
                        .font(.system(size: 16))
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
    }
}
