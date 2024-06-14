//
//  StatusBarSplitTerminalButton.swift
//  Aurora Editor
//
//  Created by Stef Kors on 14/04/2022.
//  Copyright © 2023 Aurora Company. All rights reserved.
//

import SwiftUI

/// A button to split the terminal.
internal struct StatusBarSplitTerminalButton: View {

    /// The model of the status bar.
    @ObservedObject
    private var model: StatusBarModel

    /// Initialize with model.
    internal init(model: StatusBarModel) {
        self.model = model
    }

    /// The view body.
    internal var body: some View {
        Button {
            // todo
        } label: {
            Image(systemName: "square.split.2x1")
                .foregroundColor(.secondary)
        }
        .buttonStyle(.plain)
    }
}

struct StatusBarSplitTerminalButton_Previews: PreviewProvider {
    static var previews: some View {
        let url = URL(string: "~/Developer")!
        StatusBarSplitTerminalButton(model: StatusBarModel(workspaceURL: url))
    }
}
