//
//  TextEditingPreferencesView.swift
//  Aurora Editor
//
//  Created by Lukas Pistrol on 30.03.22.
//

import SwiftUI

/// A view that implements the `Text Editing` preference section
public struct TextEditingPreferencesView: View {

    @StateObject
    private var prefs: AppPreferencesModel = .shared

    public init() {}

    /// only allows integer values in the range of `[1...8]`
    private var numberFormat: NumberFormatter {
        let formatter = NumberFormatter()
        formatter.allowsFloats = false
        formatter.minimum = 1
        formatter.maximum = 8

        return formatter
    }

    public var body: some View {
        PreferencesContent {
            GroupBox {
                HStack {
                    Text("Default Tab Width")
                    Spacer()
                    HStack(spacing: 5) {
                        TextField("", value: $prefs.preferences.textEditing.defaultTabWidth, formatter: numberFormat)
                            .multilineTextAlignment(.trailing)
                            .frame(width: 40)
                        Stepper("Default Tab Width:",
                                value: $prefs.preferences.textEditing.defaultTabWidth,
                                in: 1...8)
                        .labelsHidden()
                        Text("spaces")
                    }
                }
                .padding(.top, 5)
                .padding(.horizontal)

                Divider()

                fontSelector
                    .padding(.horizontal)

                Divider()

                minimap
                    .padding(.bottom, 5)
                    .padding(.horizontal)

                Divider()

                scopes
                    .padding(.bottom, 5)
                    .padding(.horizontal)
            }
            .padding(.bottom)

            Text("Editor Completion")
                .fontWeight(.bold)
                .padding(.horizontal)

            GroupBox {
                autocompleteBraces
                    .padding(.horizontal)
                Divider()
                enableTypeOverCompletion
                    .padding(.horizontal)
            }
        }
    }

    @ViewBuilder
    private var fontSelector: some View {
        HStack {
            Text("Font")
            Spacer()
            Picker("Font:", selection: $prefs.preferences.textEditing.font.customFont) {
                Text("System Font")
                    .tag(false)
                Text("Custom")
                    .tag(true)
            }
            .labelsHidden()
            .fixedSize()
            if prefs.preferences.textEditing.font.customFont {
                FontPicker(
                    "\(prefs.preferences.textEditing.font.name) \(prefs.preferences.textEditing.font.size)",
                    name: $prefs.preferences.textEditing.font.name, size: $prefs.preferences.textEditing.font.size
                )
            }
        }
    }

    private var minimap: some View {
        HStack {
            Text("Show Minimap")
            Spacer()
            Toggle("", isOn: $prefs.preferences.textEditing.showMinimap)
                .toggleStyle(.switch)
                .labelsHidden()
        }
    }

    private var scopes: some View {
        HStack {
            Text("Show Scopes")
            Spacer()
            Toggle("", isOn: $prefs.preferences.textEditing.showScopes)
                .toggleStyle(.switch)
                .labelsHidden()
        }
    }

    private var autocompleteBraces: some View {
        HStack {
            Text("Autocomplete braces")
            Spacer()
            Toggle("Autocomplete braces", isOn: $prefs.preferences.textEditing.autocompleteBraces)
                .toggleStyle(.switch)
                .labelsHidden()
        }
    }

    private var enableTypeOverCompletion: some View {
        HStack {
            Text("Enable type-over completion")
            Spacer()
            Toggle("Enable type-over completion", isOn: $prefs.preferences.textEditing.enableTypeOverCompletion)
                .toggleStyle(.switch)
                .labelsHidden()
        }
    }
}

struct TextEditingPreferencesView_Previews: PreviewProvider {
    static var previews: some View {
        TextEditingPreferencesView()
    }
}
