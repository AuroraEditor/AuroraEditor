//
//  EditorThemeAttributeView.swift
//  Aurora Editor
//
//  Created by TAY KAI QUAN on 9/10/22.
//  Copyright © 2023 Aurora Company. All rights reserved.
//

import SwiftUI

/// A view that represents a single attribute in the editor theme settings.
struct EditorThemeAttributeView: View {
    /// Theme settings
    @State
    var setting: ThemeSetting // NOTE: This is HIGHLY UNRELIABLE to use.

    /// Theme model
    @StateObject
    private var themeModel: ThemeModel = .shared

    /// Isbold
    @State
    var isBold: Bool = false

    /// IsItalic
    @State
    var isItalic: Bool = false

    /// IsUnderline
    @State
    var isUnderline: Bool = false

    /// The view body
    var body: some View {
        GroupBox {
            HStack {
                VStack(alignment: .leading) {
                    // TODO: Get this working with multiple scopes
//                    TextField("Scope Name", text: .init(get: { setting.scope }, set: { newScope in
//                        let selectedTheme = (themeModel.selectedTheme ?? themeModel.themes.first!)
//                            .editor.highlightTheme
//                        // get the index of the setting, and ensure that the scope that the user
//                        // is trying to change the name to is not preexisting
//                        guard let settingIndex = selectedTheme.settings.firstIndex(where: {
//                            $0.scope == setting.scope}),
//                              selectedTheme.settings.contains(where: { $0.scope == newScope })
//                        else { return }
//
//                        selectedTheme.settings[settingIndex].scope = newScope
//
//                        // update the root
//                        selectedTheme.root = HighlightTheme
//                            .createTrie(settings: selectedTheme.settings)
//                    }))
                    HStack {
                        // The text's color, defaults to default text color of theme
                        PreferencesColorPicker(.init(get: {
                            let attribute = (setting.attributes.first(where: {
                                $0 is ColorThemeAttribute
                            }) as? ColorThemeAttribute)

                            if let color = attribute?.color {
                                return Color(nsColor: color)
                            } else {
                                return (
                                    themeModel.selectedTheme ?? themeModel.defaultTheme
                                ).editor.text.swiftColor
                            }
                        }, set: { newColor in
                            replaceAttribute(setting: setting,
                                             existingTest: { $0 is ColorThemeAttribute },
                                             with: ColorThemeAttribute(color: NSColor(newColor)))
                        }))
                        // BIU options
                        HStack {
                            Image(systemName: "bold")
                                .frame(width: 23, height: 23)
                                .background(isBold ?
                                            Color.accentColor : Color.gray.opacity(0.5))
                                .foregroundColor(isBold ?
                                                 Color(nsColor: NSColor.labelColor) :
                                                    Color(nsColor: NSColor.secondaryLabelColor))
                                .cornerRadius(5)
                                .accessibilityLabel(Text("Bold"))
                                .onTapGesture {
                                    var doesExist = false
                                    replaceAttribute(setting: setting,
                                                     existingTest: {
                                        let isMatch = $0 is BoldThemeAttribute
                                        doesExist = isMatch || doesExist
                                        return isMatch
                                    },
                                                     toggleMode: true,
                                                     with: BoldThemeAttribute())
                                    isBold = !doesExist
                                }
                                .accessibilityAddTraits(.isButton)
                            Image(systemName: "italic")
                                .frame(width: 23, height: 23)
                                .accessibilityLabel(Text("Italic"))
                                .background(isItalic ?
                                            Color.accentColor : Color.gray.opacity(0.5))
                                .foregroundColor(isItalic ?
                                                 Color(nsColor: NSColor.labelColor) :
                                                    Color(nsColor: NSColor.secondaryLabelColor))
                                .cornerRadius(5)
                                .onTapGesture {
                                    var doesExist = false
                                    replaceAttribute(setting: setting,
                                                     existingTest: {
                                        let isMatch = $0 is ItalicThemeAttribute
                                        doesExist = isMatch || doesExist
                                        return isMatch
                                    },
                                                     toggleMode: true,
                                                     with: ItalicThemeAttribute())
                                    isItalic = !doesExist
                                }
                                .accessibilityAddTraits(.isButton)
                            Image(systemName: "underline")
                                .frame(width: 23, height: 23)
                                .accessibilityLabel(Text("Underline"))
                                .background(isUnderline ?
                                            Color.accentColor : Color.gray.opacity(0.5))
                                .foregroundColor(isUnderline ?
                                                 Color(nsColor: NSColor.labelColor) :
                                                    Color(nsColor: NSColor.secondaryLabelColor))
                                .cornerRadius(5)
                                .onTapGesture {
                                    var doesExist = false
                                    replaceAttribute(setting: setting,
                                                     existingTest: {
                                        let isMatch = $0 is UnderlineThemeAttribute
                                        doesExist = isMatch || doesExist
                                        return isMatch
                                    },
                                                     toggleMode: true,
                                                     with: UnderlineThemeAttribute(color:
                                                            .labelColor))
                                    isUnderline = !doesExist
                                }
                                .accessibilityAddTraits(.isButton)
                        }
                    }
                }
                Spacer()
            }
            .padding(.horizontal, 5)
        }
        .padding(.horizontal, 7)
        .onAppear {
            isBold = setting.attributes.contains(where: { $0 is BoldThemeAttribute })
            isItalic = setting.attributes.contains(where: { $0 is ItalicThemeAttribute })
            isUnderline = setting.attributes.contains(where: { $0 is UnderlineThemeAttribute })
        }
        .contextMenu {
            Button("global.delete") {
                guard let selectedTheme = themeModel.selectedTheme?.editor.highlightTheme else { return }
                withAnimation {
                    selectedTheme.settings.removeAll(where: {
                        $0.scopes == setting.scopes
                    })
                    themeModel.objectWillChange.send()
                }
            }
        }
    }

    /// Replace an attribute in the theme settings
    /// 
    /// - Parameter setting: The setting to replace
    /// - Parameter existingTest: The test to check if the attribute exists
    /// - Parameter toggleMode: Whether to remove the attribute if found
    /// - Parameter newAttribute: The new attribute to replace with
    func replaceAttribute(setting: ThemeSetting,
                          existingTest: @escaping (ThemeAttribute) -> Bool,
                          toggleMode: Bool = false, // removes an attribute when found, if set to true
                          with newAttribute: ThemeAttribute? = nil) {
        // get the index of the setting
        guard let selectedTheme = themeModel.selectedTheme?.editor.highlightTheme,
              let settingIndex = selectedTheme.settings.firstIndex(where: {
            $0.scopes == setting.scopes
        }) else { return }
        let setting = selectedTheme.settings[settingIndex]

        // Get the location of any existing ColorThemeAttribute
        let attributeIndex = setting.attributes.firstIndex(where: existingTest)

        // Insert the new attribute, replacing any and all existing ones matching the conditions.
        if let attributeIndex = attributeIndex {
            selectedTheme.settings[settingIndex].attributes.removeAll(where: existingTest)
            if let newAttribute = newAttribute, !toggleMode {
                selectedTheme.settings[settingIndex].attributes.insert(newAttribute, at: attributeIndex)
            }
        } else {
            if let newAttribute = newAttribute {
                selectedTheme.settings[settingIndex].attributes.append(newAttribute)
            }
        }

        // update the root
        selectedTheme.root = HighlightTheme
            .createTrie(settings: selectedTheme.settings)
    }
}
