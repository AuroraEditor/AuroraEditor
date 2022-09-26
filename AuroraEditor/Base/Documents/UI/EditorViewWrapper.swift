//
//  EditorViewWrapper.swift
//  AuroraEditor
//
//  Created by TAY KAI QUAN on 26/9/22.
//  Copyright © 2022 Aurora Company. All rights reserved.
//

import SwiftUI

public struct EditorViewWrapper: View {
    @ObservedObject
    private var codeFile: CodeFileDocument

    @ObservedObject
    private var prefs: AppPreferencesModel = .shared

    @ObservedObject
    private var sharedObjects: SharedObjects = .shared

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

    @State private var position: CodeEditor.Position = CodeEditor.Position()
    @State private var messages: Set<Located<Message>> = Set()

    public var body: some View {
        GeometryReader { proxy in
            EditorFileView(size: proxy.size, text: $codeFile.content)
        }
        .environment(\.codeEditorTheme,
                      colorScheme == .dark ? Theme.defaultDark : Theme.defaultLight)
    }
}
