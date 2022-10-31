//
//  ExploreExtensionsView.swift
//  AuroraEditor
//
//  Created by Nanashi Li on 2022/10/29.
//  Copyright © 2022 Aurora Company. All rights reserved.
//

import SwiftUI

struct ExploreExtensionsView: View {

    @ObservedObject
    private var extensionsModel: ExtensionInstallationViewModel = .init()

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
                List {
                    ForEach(extensionsModel.extensions) { plugin in
                        ExploreItemView(extensionData: plugin,
                                        extensionsModel: extensionsModel)
                            .tag(plugin.id)
                    }
                }
                .listStyle(.sidebar)
                .listRowInsets(.init())
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

struct ExploreExtensionsView_Previews: PreviewProvider {
    static var previews: some View {
        ExploreExtensionsView()
    }
}
