//
//  StatusBarBreakpointButton.swift
//  Aurora Editor
//
//  Created by Stef Kors on 14/04/2022.
//  Copyright © 2023 Aurora Company. All rights reserved.
//

import SwiftUI

/// A button that toggles the breakpoint state.
internal struct StatusBarBreakpointButton: View {
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
            model.isBreakpointEnabled.toggle()
        } label: {
            if model.isBreakpointEnabled {
                Image.breakpointFill
                    .foregroundColor(.accentColor)
            } else {
                Image.breakpoint
                    .foregroundColor(.secondary)
            }
        }
        .buttonStyle(.plain)
    }
}

struct StatusBarBreakpointButton_Previews: PreviewProvider {
    static var previews: some View {
        let url = URL(string: "~/Developer")!
        StatusBarBreakpointButton(model: StatusBarModel(workspaceURL: url))
    }
}
