//
//  SwiftUIView.swift
//  Aurora Editor
//
//  Created by Lukas Pistrol on 13.04.22.
//  Copyright © 2023 Aurora Company. All rights reserved.
//

import SwiftUI

/// A toolbar for the preferences
struct PreferencesToolbar<T: View>: View {
    /// The height
    private let height: Double

    /// The content
    private let content: () -> T

    /// Initializes a new preferences toolbar
    /// 
    /// - Parameter height: The height
    /// - Parameter bgColor: The background color
    /// - Parameter content: The content
    init(
        height: Double = 27,
        bgColor: Color = Color(NSColor.controlBackgroundColor),
        @ViewBuilder content: @escaping () -> T
    ) {
        self.height = height
        self.content = content
    }

    /// The view body
    var body: some View {
        ZStack {
            EffectView(.contentBackground)
            HStack {
                content()
                    .padding(.horizontal, 8)
            }
        }
        .frame(height: height)
    }
}
