//
//  StatusBarLineEndSelector.swift
//  Aurora Editor
//
//  Created by Lukas Pistrol on 22.03.22.
//  Copyright © 2023 Aurora Company. All rights reserved.
//

import SwiftUI

internal struct StatusBarLineEndSelector: View {
    @ObservedObject
    private var model: StatusBarModel

    internal init(model: StatusBarModel) {
        self.model = model
    }

    internal var body: some View {
        Menu {
            // LF, CRLF
        } label: {
            StatusBarMenuLabel("LF", model: model)
        }
        .menuIndicator(.hidden)
        .menuStyle(.borderlessButton)
        .fixedSize()
        .onHover { isHovering($0) }
    }
}
