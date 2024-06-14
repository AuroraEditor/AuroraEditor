//
//  StatusBarMenuLabel.swift
//  Aurora Editor
//
//  Created by Axel Zuziak on 24.04.2022.
//  Copyright © 2023 Aurora Company. All rights reserved.
//

import SwiftUI

/// A view that displays Text with custom chevron up/down symbol
internal struct StatusBarMenuLabel: View {

    /// The text to display
    private let text: String

    /// The model of the status bar
    @ObservedObject
    private var model: StatusBarModel

    /// Initialize with text and model
    /// 
    /// - Parameter text: The text to display
    /// - Parameter model: The statusbar model
    internal init(_ text: String, model: StatusBarModel) {
        self.text = text
        self.model = model
    }

    /// The view body
    internal var body: some View {
        Text(text + "  ")
            .font(model.toolbarFont) +
        Text(Image.customChevronUpChevronDown)
            .font(model.toolbarFont)
    }
}
