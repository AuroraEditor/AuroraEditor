//
//  StatusBarEncodingSelector.swift
//  Aurora Editor
//
//  Created by Lukas Pistrol on 22.03.22.
//  Copyright © 2023 Aurora Company. All rights reserved.
//

import SwiftUI

/// A selector for the encoding of the status bar.
internal struct StatusBarEncodingSelector: View {

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
        Menu {
            // UTF 8, ASCII, ...
        } label: {
            StatusBarMenuLabel("UTF 8", model: model)
        }
        .menuIndicator(.hidden)
        .menuStyle(.borderlessButton)
        .fixedSize()
        .onHover { isHovering($0) }
    }
}
