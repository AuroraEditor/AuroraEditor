//
//  HStackToggle.swift
//  Aurora Editor
//
//  Created by Nanashi Li on 16/09/2023.
//  Copyright © 2023 Aurora Company. All rights reserved.
//

import SwiftUI

/// A view that represents a horizontal stack toggle.
struct HStackToggle: View {
    /// The text of the toggle.
    @State
    public var text: String

    /// The toggle value binding.
    @Binding
    public var toggleValue: Bool

    /// The view body
    var body: some View {
        HStack(alignment: .center) {
            Text(text)
                .font(.system(size: 13,
                              weight: .medium))
            Spacer()
            Toggle("", isOn: $toggleValue)
                .labelsHidden()
                .toggleStyle(.switch)
        }
        .padding(.horizontal)
    }
}
