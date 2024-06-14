//
//  ExtensionNavigatorItem.swift
//  Aurora Editor
//
//  Created by Pavel Kasila on 7.04.22.
//  Copyright © 2023 Aurora Company. All rights reserved.
//

import SwiftUI

/// Extension navigator item.
struct ExtensionNavigatorItem: View {

    /// Workspace document
    @EnvironmentObject
    var document: WorkspaceDocument

    /// View body
    var body: some View {
        Button {
//            document.openTab(item: plugin)
        } label: {
            ZStack {
                HStack {
                    VStack(alignment: .leading) {
//                        Text(plugin.manifest.displayName)
//                            .font(.headline)
//                        Text(plugin.manifest.name)
//                            .font(.subheadline)
                    }
                    Spacer()
                }
            }
        }
        .buttonStyle(.plain)
    }
}
