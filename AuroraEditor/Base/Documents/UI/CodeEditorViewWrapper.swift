//
//  CodeEditorViewWrapper.swift
//  Aurora Editor
//
//  Created by TAY KAI QUAN on 17/9/22.
//  Copyright © 2023 Aurora Company. All rights reserved.
//

import SwiftUI
import AuroraEditorTextView
import AuroraEditorInputView
import AuroraEditorLanguage

public struct CodeEditorViewWrapper: View {
    @ObservedObject
    private var codeFile: CodeFileDocument

    @ObservedObject
    private var prefs: AppPreferencesModel = .shared

    @ObservedObject
    private var themeModel: ThemeModel = .shared

    @EnvironmentObject
    private var workspace: WorkspaceDocument

    @State
    private var fileExtension: String

    @State
    private var theme: AuroraTheme

    @State
    private var breadcrumbItem: FileItem?

    private let editable: Bool

    private let undoManager = CEUndoManager()

    public init(codeFile: CodeFileDocument,
                editable: Bool = true,
                fileExtension: String = "txt",
                breadcrumbItem: FileItem? = nil) {
        self.codeFile = codeFile
        self.editable = editable
        self.fileExtension = fileExtension
        self.breadcrumbItem = breadcrumbItem
        let currentTheme = ThemeModel.shared.selectedTheme
        ?? ThemeModel.shared.themes.first
        ?? .init(
            editor: .defaultLight,
            terminal: .defaultLight,
            author: "N/A",
            license: "MIT",
            metadataDescription: "N/A",
            distributionURL: "N/A",
            name: "Default",
            displayName: "Default",
            appearance: .light,
            version: "0"
        )
        self.theme = currentTheme
    }

    @State
    private var font: NSFont = {
        let size = AppPreferencesModel.shared.preferences.textEditing.font.size
        let name = AppPreferencesModel.shared.preferences.textEditing.font.name
        return NSFont(name: name, size: Double(size)) ?? NSFont.monospacedSystemFont(ofSize: 12, weight: .regular)
    }()

    @State private var selectedTheme = ThemeModel.shared.selectedTheme
    @State var cursorPosition = [CursorPosition(line: 1, column: 1)]

    public var body: some View {
        AuroraEditorTextView($codeFile.content,
                             language: getLanguage(),
                             theme: .init(text: NSColor(hex: "#D9D9D9"),
                                          insertionPoint: NSColor(hex: "#D9D9D9"),
                                          invisibles: NSColor(hex: "#D9D9D9"),
                                          background: NSColor(hex: "#292a30"),
                                          lineHighlight: NSColor(hex: "#2f3239"),
                                          selection: NSColor(hex: "#2f3239"),
                                          keywords: NSColor(hex: "#FC5FA3"),
                                          commands: NSColor(hex: "#D9D9D9"),
                                          types: NSColor(hex: "#5DD8FF"),
                                          attributes: NSColor(hex: "#D9D9D9"),
                                          variables: NSColor(hex: "#D9D9D9"),
                                          values: NSColor(hex: "#D9D9D9"),
                                          numbers: NSColor(hex: "#D7C986"),
                                          strings: NSColor(hex: "#FC6A5D"),
                                          characters: NSColor(hex: "#D0BF69"),
                                          comments: NSColor(hex: "#6C7986")),
                             font: font,
                             tabWidth: 4,
                             lineHeight: 1.45,
                             wrapLines: true,
                             cursorPositions: $cursorPosition,
                             bracketPairHighlight: .flash)
        .onChange(of: themeModel.selectedTheme, perform: { newTheme in
            self.theme = newTheme ?? themeModel.themes.first!
        })
    }

    private func getLanguage() -> CodeLanguage {
        return CodeLanguage.detectLanguageFrom(url: codeFile.fileURL!)
    }
}
