//
//  AECodeView.swift
//  AuroraEditor
//
//  Created by TAY KAI QUAN on 17/9/22.
//  Copyright © 2022 Aurora Company. All rights reserved.
//

import SwiftUI

public struct AECodeView: View {
    @ObservedObject
    private var codeFile: CodeFileDocument

    @ObservedObject
    private var prefs: AppPreferencesModel = .shared

    @Environment(\.colorScheme)
    private var colorScheme

    private let editable: Bool

    public init(codeFile: CodeFileDocument, editable: Bool = true) {
        self.codeFile = codeFile
        self.editable = editable
    }

    @State
    private var selectedTheme = ThemeModel.shared.selectedTheme ?? ThemeModel.shared.themes.first!

    @State
    private var font: NSFont = {
        let size = AppPreferencesModel.shared.preferences.textEditing.font.size
        let name = AppPreferencesModel.shared.preferences.textEditing.font.name
        return NSFont(name: name, size: Double(size)) ?? NSFont.monospacedSystemFont(ofSize: 12, weight: .regular)
    }()

    private var themeString: String? {
        return ThemeModel.shared.selectedTheme?.highlightrThemeString
    }

    private func getLanguage() -> CodeLanguage? {
        if let url = codeFile.fileURL {
            return .detectLanguageFromUrl(url: url)
        } else {
            return .default
        }
    }

    @State private var position: CodeEditor.Position  = CodeEditor.Position()
    @State private var messages: Set<Located<Message>> = Set()

    public var body: some View {
        AuroraEditorTextView(
            $codeFile.content,
            font: $font,
            tabWidth: $prefs.preferences.textEditing.defaultTabWidth,
            lineHeight: .constant(1.2),
            language: getLanguage(),
            themeString: themeString
        )
        .id(codeFile.fileURL)
        .background(selectedTheme.editor.background.swiftColor)
        .disabled(!editable)
        .frame(maxHeight: .infinity)
        .onChange(of: ThemeModel.shared.selectedTheme) { newValue in
            guard let theme = newValue else { return }
            self.selectedTheme = theme
        }
        .onChange(of: prefs.preferences.textEditing.font) { _ in
            font = NSFont(
                name: prefs.preferences.textEditing.font.name,
                size: Double(prefs.preferences.textEditing.font.size)
            ) ?? .monospacedSystemFont(ofSize: 12, weight: .regular)
        }
    }
}
