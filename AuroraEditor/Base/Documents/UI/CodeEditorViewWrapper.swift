//
//  CodeEditorViewWrapper.swift
//  Aurora Editor
//
//  Created by TAY KAI QUAN on 17/9/22.
//  Copyright © 2023 Aurora Company. All rights reserved.
//

import SwiftUI
import AuroraEditorTextView
import AuroraEditorLanguage
import AuroraEditorSourceEditor

/// A view that wraps the code editor view.
public struct CodeEditorViewWrapper: View {
    /// The code file document
    @ObservedObject
    private var codeFile: CodeFileDocument

    /// The preferences model
    @ObservedObject
    private var prefs: AppPreferencesModel = .shared

    /// The theme model
    @ObservedObject
    private var themeModel: ThemeModel = .shared

    /// The workspace document
    @EnvironmentObject
    private var workspace: WorkspaceDocument

    /// The file extension
    @State
    private var fileExtension: String

    /// The active theme
    @State
    private var theme: AuroraTheme

    /// The breadcrumb item
    @State
    private var breadcrumbItem: FileItem?

    /// Is editable state
    private let editable: Bool

    /// Code editor view wrapper initializer
    /// 
    /// - Parameter codeFile: The code file document
    /// - Parameter editable: Is editable
    /// - Parameter fileExtension: The file extension
    /// - Parameter breadcrumbItem: The breadcrumb item
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

    /// The current font
    @State
    private var font: NSFont = {
        let size = AppPreferencesModel.shared.preferences.editorFont.size
        let name = AppPreferencesModel.shared.preferences.editorFont.name
        return NSFont(name: name, size: Double(size)) ?? NSFont.monospacedSystemFont(ofSize: 12, weight: .regular)
    }()

    /// The selected theme
    @State
    private var selectedTheme = ThemeModel.shared.selectedTheme

    /// The cursor position
    @State
    var cursorPosition = [CursorPosition(line: 1, column: 1)]

    /// Undo manager
    var undoManager: AEUndoManager = .init()

    /// Default theme
    let defaultTheme: EditorTheme = .init(
        text: NSColor(hex: "#D9D9D9"),
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
        comments: NSColor(hex: "#6C7986")
    )

    /// The view body
    public var body: some View {
        AuroraEditorSourceEditor(
            $codeFile.content,
            language: getLanguage(),
            theme: defaultTheme,
            font: font,
            tabWidth: 4, // TODO: Add this in settings
            indentOption: .spaces(count: 4), // TODO: Add this in settings
            lineHeight: 1.45, // TODO: Add this in settings
            wrapLines: true, // TODO: Add this in settings
            cursorPositions: $cursorPosition,
            useThemeBackground: true,
            contentInsets: nil, // TODO: Add this in settings
            isEditable: true,
            letterSpacing: 1, // TODO: Add this in settings
            bracketPairHighlight: nil,
            undoManager: undoManager,
            coordinators: []
        )
        .onChange(of: themeModel.selectedTheme, perform: { newTheme in
            self.theme = newTheme ?? themeModel.themes.first!
        })
        .onChange(of: cursorPosition) { newValue in
            self.workspace.data.caretPos = .init(
                line: newValue[0].line,
                column: newValue[0].column
            )
        }
    }

    /// Get the language
    /// 
    /// - Returns: The code language
    private func getLanguage() -> CodeLanguage {
        guard let url = codeFile.fileURL else {
            guard let plainText = CodeLanguage.allLanguages.first(where: { $0.tsName == "PlainText" }) else {
                fatalError("Unable to get plain text code language")
            }

            return plainText
        }

        return CodeLanguage.detectLanguageFrom(url: url)
    }
}
