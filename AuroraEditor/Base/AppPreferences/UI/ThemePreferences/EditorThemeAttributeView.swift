//
//  EditorThemeAttributeView.swift
//  AuroraEditor
//
//  Created by TAY KAI QUAN on 9/10/22.
//  Copyright © 2022 Aurora Company. All rights reserved.
//

import SwiftUI

struct EditorThemeAttributeView: View {

    @State
    var setting: ThemeSetting // NOTE: This is HIGHLY UNRELIABLE to use.

    @StateObject
    private var themeModel: ThemeModel = .shared

    @State
    var isBold: Bool = false

    @State
    var isItalic: Bool = false

    @State
    var isUnderline: Bool = false

    var body: some View {
        GroupBox {
            HStack {
                VStack(alignment: .leading) {
                    // TODO: Allow horizontal overflow on this
                    TextField("Scope Name", text: .init(get: { setting.scope }, set: { newScope in
                        let selectedTheme = (themeModel.selectedTheme ?? themeModel.themes.first!)
                            .editor.highlightTheme
                        // get the index of the setting, and ensure that the scope that the user
                        // is trying to change the name to is not preexisting
                        guard let settingIndex = selectedTheme.settings.firstIndex(where: {
                            $0.scope == setting.scope}),
                              selectedTheme.settings.contains(where: { $0.scope == newScope })
                        else { return }

                        selectedTheme.settings[settingIndex].scope = newScope

                        // update the root
                        selectedTheme.root = HighlightTheme
                            .createTrie(settings: selectedTheme.settings)
                    }))
                    HStack {
                        // The text's color, defaults to default text color of theme
                        PreferencesColorPicker(.init(get: {
                            let attribute = (setting.attributes.first(where: {
                                $0 is ColorThemeAttribute
                            }) as? ColorThemeAttribute)

                            if let color = attribute?.color {
                                return Color(nsColor: color)
                            } else {
                                return (themeModel.selectedTheme ?? themeModel.themes.first!)
                                    .editor.text.swiftColor
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
                            Image(systemName: "italic")
                                .frame(width: 23, height: 23)
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
                            Image(systemName: "underline")
                                .frame(width: 23, height: 23)
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
    }

    func replaceAttribute(setting: ThemeSetting,
                          existingTest: @escaping (ThemeAttribute) -> Bool,
                          toggleMode: Bool = false, // removes an attribute when found, if set to true
                          with newAttribute: ThemeAttribute? = nil) {
        let selectedTheme = (themeModel.selectedTheme ?? themeModel.themes.first!).editor.highlightTheme
        // get the index of the setting
        guard let settingIndex = selectedTheme.settings.firstIndex(where: {
            $0.scope == setting.scope
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
