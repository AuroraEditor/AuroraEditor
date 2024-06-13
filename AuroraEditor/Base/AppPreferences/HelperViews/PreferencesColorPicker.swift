//
//  PreferencesColorPicker.swift
//  Aurora Editor
//
//  Created by Lukas Pistrol on 31.03.22.
//  Copyright © 2023 Aurora Company. All rights reserved.
//

import SwiftUI

/// A color picker for the preferences
struct PreferencesColorPicker: View {
    @Binding
    /// Color
    var color: Color

    @State
    /// Selected color
    private var selectedColor: Color

    /// Label
    private let label: String?

    /// Initializes a new color picker
    /// 
    /// - Parameter color: The color
    /// - Parameter label: The label
    init(_ color: Binding<Color>, label: String? = nil) {
        self._color = color
        self.label = label
        self._selectedColor = State(initialValue: color.wrappedValue)
    }

    /// The view body
    var body: some View {
        HStack {
            ColorPicker(selection: $selectedColor, supportsOpacity: false) { }
                .labelsHidden()
            if let label = label {
                Text(.init(label))
            }
        }.onChange(of: selectedColor) { newValue in
            color = newValue
        }
    }
}
