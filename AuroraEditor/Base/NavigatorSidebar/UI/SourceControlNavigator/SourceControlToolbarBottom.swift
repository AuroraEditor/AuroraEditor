//
//  SourceControlToolbarBottom.swift
//  Aurora Editor
//
//  Created by Nanashi Li on 2022/05/20.
//  Copyright © 2023 Aurora Company. All rights reserved.
//

import SwiftUI

struct SourceControlToolbarBottom: View {
    var body: some View {
        HStack(spacing: 0) {
            sourceControlMenu
            SourceControlSearchToolbar()
        }
        .frame(height: 29, alignment: .center)
        .frame(maxWidth: .infinity)
        .padding(.horizontal, 4)
        .overlay(alignment: .top) {
            Divider()
        }
    }

    private var sourceControlMenu: some View {
        Menu {
            Button("Discard Changes...") {}
                .disabled(true) // TODO: Implementation Needed
            Button("Stash Changes...") {}
                .disabled(true) // TODO: Implementation Needed
            Button("Create Pull Request...") {}
                .disabled(true) // TODO: Implementation Needed
        } label: {
            Image(systemName: "ellipsis.circle")
        }
        .menuStyle(.borderlessButton)
        .menuIndicator(.hidden)
        .frame(maxWidth: 30)
    }
}

struct SourceControlToolbarBottom_Previews: PreviewProvider {
    static var previews: some View {
        SourceControlToolbarBottom()
    }
}
