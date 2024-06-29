//
//  StatusBarDrawer.swift
//  Aurora Editor
//
//  Created by Lukas Pistrol on 22.03.22.
//  Copyright © 2023 Aurora Company. All rights reserved.
//

import SwiftUI

/// The drawer of the status bar.
internal struct StatusBarDrawer: View {
    /// The model of the status bar.
    @ObservedObject
    private var model: StatusBarModel

    /// The search text.
    @State
    private var searchText = ""

    /// Initialize with model.
    /// 
    /// - Parameter model: The statusbar model.
    internal init(model: StatusBarModel) {
        self.model = model
    }

    /// The height of the drawer.
    var height: CGFloat {
        if model.isMaximized {
            return model.maxHeight
        }
        if model.isExpanded {
            return model.currentHeight
        }
        return 0
    }

    /// The view body.
    internal var body: some View {
        VStack(spacing: 0) {
            switch model.selectedTab {
            case 0: TerminalEmulatorView(url: model.workspaceURL)
            default: Rectangle().foregroundColor(Color(nsColor: .textBackgroundColor))
            }
            HStack(alignment: .center, spacing: 10) {
                FilterTextField(title: "Filter", text: $searchText)
                    .frame(maxWidth: 300)
                Spacer()
                StatusBarClearButton(model: model)
                Divider()
                StatusBarSplitTerminalButton(model: model)
                StatusBarMaximizeButton(model: model)
            }
            .padding(10)
            .frame(maxHeight: 29)
            .background(.bar)
        }
        .frame(minHeight: 0,
               idealHeight: height,
               maxHeight: height)
    }
}
