//
//  CodeEditorViewWrapper.swift
//  AuroraEditor
//
//  Created by TAY KAI QUAN on 17/9/22.
//  Copyright © 2022 Aurora Company. All rights reserved.
//

import SwiftUI

public struct CodeEditorViewWrapper: View {
    @ObservedObject
    private var codeFile: CodeFileDocument

    @ObservedObject
    private var prefs: AppPreferencesModel = .shared

    @ObservedObject
    private var sharedObjects: SharedObjects = .shared

    @ObservedObject
    private var themeModel: ThemeModel = .shared

    @State
    private var theme: AuroraTheme

    private let editable: Bool

    public init(codeFile: CodeFileDocument, editable: Bool = true) {
        self.codeFile = codeFile
        self.editable = editable
        let currentTheme = ThemeModel.shared.selectedTheme ?? ThemeModel.shared.themes.first!
        self.theme = currentTheme
    }

    @State
    private var font: NSFont = {
        let size = AppPreferencesModel.shared.preferences.textEditing.font.size
        let name = AppPreferencesModel.shared.preferences.textEditing.font.name
        return NSFont(name: name, size: Double(size)) ?? NSFont.monospacedSystemFont(ofSize: 12, weight: .regular)
    }()

    @State private var position: CodeEditor.Position = CodeEditor.Position()
    @State private var messages: Set<Located<Message>> = Set()

    public var body: some View {
        CodeEditor(
            text: $codeFile.content,
            position: $position,
            caretPosition: $sharedObjects.caretPos,
            currentToken: $sharedObjects.currentToken,
            messages: $messages,
            theme: $theme,
            layout: CodeEditor.LayoutConfiguration(showMinimap: prefs.preferences.textEditing.showMinimap)
        )
        .onChange(of: themeModel.selectedTheme, perform: { newTheme in
            self.theme = newTheme ?? themeModel.themes.first!
        })
    }
}
