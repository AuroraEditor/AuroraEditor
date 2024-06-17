//
//  StatusBarClearButton.swift
//  Aurora Editor
//
//  Created by Stef Kors on 12/04/2022.
//  Copyright © 2023 Aurora Company. All rights reserved.
//

import SwiftUI

/// A button to clear the terminal.
internal struct StatusBarClearButton: View {
    /// The model of the status bar.
    @ObservedObject
    private var model: StatusBarModel

    /// Initialize with model.
    /// 
    /// - Parameter model: The statusbar model.
    internal init(model: StatusBarModel) {
        self.model = model
    }

    /// The view body.
    internal var body: some View {
        Button {
            // Clear terminal
        } label: {
            Image(systemName: "trash")
                .foregroundColor(.secondary)
                .accessibilityLabel(Text("Clear Terminal"))
        }
        .buttonStyle(.plain)
    }
}

struct StatusBarClearButton_Previews: PreviewProvider {
    static var previews: some View {
        let url = URL(string: "~/Developer")!
        StatusBarClearButton(model: StatusBarModel(workspaceURL: url))
    }
}
