//
//  ExtensionNavigatorItem.swift
//  Aurora Editor
//
//  Created by Pavel Kasila on 7.04.22.
//  Copyright © 2023 Aurora Company. All rights reserved.
//
//  This file originates from CodeEdit, https://github.com/CodeEditApp/CodeEdit

import SwiftUI

struct ExtensionNavigatorItem: View {
    @EnvironmentObject var document: WorkspaceDocument

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
