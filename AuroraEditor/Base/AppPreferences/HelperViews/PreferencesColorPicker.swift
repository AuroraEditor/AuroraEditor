//
//  PreferencesColorPicker.swift
//  Aurora Editor
//
//  Created by Lukas Pistrol on 31.03.22.
//  Copyright © 2023 Aurora Company. All rights reserved.
//

import SwiftUI

struct PreferencesColorPicker: View {

    @Binding
    var color: Color

    @State private var selectedColor: Color

    private let label: String?

    init(_ color: Binding<Color>, label: String? = nil) {
        self._color = color
        self.label = label
        self._selectedColor = State(initialValue: color.wrappedValue)
    }

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
