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
    @Environment(\.colorScheme)
    var colorScheme

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
        self.editorTheme = currentTheme.editorTheme()
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

    @State
    private var editorTheme: EditorTheme

    /// The view body
    public var body: some View {
        AuroraEditorSourceEditor(
            $codeFile.content,
            language: getLanguage(),
            theme: editorTheme,
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
        .onAppear {
            self.editorTheme = ThemeModel.shared
                .getTheme(theme, with: colorScheme == .dark ? .darkAqua : .aqua)
                .editorTheme()
        }
        .onChange(of: colorScheme) { value in
            switch value {
            case .dark:
                self.editorTheme = ThemeModel.shared
                    .getTheme(theme, with: value == .dark ? .darkAqua : .aqua)
                    .editorTheme()
            case .light:
                self.editorTheme = ThemeModel.shared
                    .getTheme(theme, with: value == .dark ? .darkAqua : .aqua)
                    .editorTheme()
            @unknown default:
                break
            }
        }
        .onChange(of: themeModel.selectedTheme, perform: { newTheme in
            guard let newTheme = newTheme else { return }
            self.theme = newTheme
            self.editorTheme = newTheme.editorTheme()
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

extension AuroraTheme {
    func editorTheme() -> EditorTheme {
        .init(
            text: editor.text.nsColor,
            insertionPoint: editor.insertionPoint.nsColor,
            invisibles: editor.invisibles.nsColor,
            background: editor.background.nsColor,
            lineHighlight: editor.lineHighlight.nsColor,
            selection: editor.selection.nsColor,
            keywords: editor.keywords.nsColor,
            commands: editor.commands.nsColor,
            types: editor.types.nsColor,
            attributes: editor.attributes.nsColor,
            variables: editor.variables.nsColor,
            values: editor.values.nsColor,
            numbers: editor.numbers.nsColor,
            strings: editor.strings.nsColor,
            characters: editor.characters.nsColor,
            comments: editor.comments.nsColor
        )
    }
}
