//
//  SourceControlToolbarBottom.swift
//  Aurora Editor
//
//  Created by Nanashi Li on 2022/05/20.
//  Copyright © 2023 Aurora Company. All rights reserved.
//

import SwiftUI

/// The bottom toolbar for source control.
struct SourceControlToolbarBottom: View {

    /// The view body.
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

    /// Source control menu.
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
                .accessibilityLabel(Text("Source Control Menu"))
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
