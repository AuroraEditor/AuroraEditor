//
//  EditorFileView.swift
//  AuroraEditor
//
//  Created by TAY KAI QUAN on 26/9/22.
//  Copyright © 2022 Aurora Company. All rights reserved.
//

import SwiftUI
import EditorCore

struct EditorFileView: NSViewRepresentable {

    typealias NSViewType = NSScrollView

    @State
    var textView: EditorTextView!

    @State
    var editor: Editor!

    @State
    var parser: Parser!

    @State
    var size: NSSize

    @Binding
    var text: String

    func makeNSView(context: Context) -> NSScrollView {
        let scrollView = NSScrollView()

        let textView = EditorTextView()
        scrollView.documentView = textView
        textView.insertionPointColor = .white
        textView.string = text
        textView.onStringChanged = { text = $0 }
        textView.selectedTextAttributes.removeValue(forKey: .foregroundColor)
        textView.linkTextAttributes?.removeValue(forKey: .foregroundColor)
        textView.replace(lineNumberGutter: LineNumberGutter(withTextView: textView))

        scrollView.scrollerStyle = .overlay
        scrollView.hasVerticalScroller = true
        scrollView.hasHorizontalScroller = false
        scrollView.contentView.automaticallyAdjustsContentInsets = false
        scrollView.contentView.contentInsets = .init(top: -10, left: 0, bottom: 200, right: 0)

        DispatchQueue.main.async {
            self.parser = Parser(grammars: [basicSwiftGrammar])
            parser.shouldDebug = false
            self.editor = Editor(textView: textView,
                                 parser: parser,
                                 baseGrammar: basicSwiftGrammar, theme: exampleTheme)
            editor.subscribe(toToken: "action") { (res) in
                for (str, range) in res {
                    Log.info("\(str) at \(range)")
                }
            }

            self.textView = textView
        }

        scrollView.documentView = textView

        return scrollView
    }

    func updateNSView(_ nsView: NSScrollView, context: Context) {
        if textView != nil {
            textView.insertionPointColor = .white
            textView.selectedTextAttributes.removeValue(forKey: .foregroundColor)
            textView.linkTextAttributes?.removeValue(forKey: .foregroundColor)
            textView.frame = nsView.bounds
            nsView.contentView.contentInsets = .init(top: -10,
                                                     left: 0,
                                                     bottom: nsView.visibleRect.height/2,
                                                     right: 0)
        }
    }
}

// swiftlint:disable:next swiftlint_file_disabling
// swiftlint:disable line_length
let basicSwiftGrammar = Grammar(
    scopeName: "source.swift",
    fileTypes: [],
    patterns: [
        MatchRule(name: "keyword.declarations", match: "\\b(associatedtype|class|deinit|enum|extension|fileprivate|func|import|init|inout|internal|let|open|operator|private|protocol|public|rethrows|static|struct|subscript|typealias|var)\\b"),
        MatchRule(name: "keyword.statements", match: "\\b(break|case|continue|default|defer|do|else|fallthrough|for|guard|if|in|repeat|return|switch|where|while)\\b"),
        MatchRule(name: "keyword.expressionsandtypes", match: "\\b(as|Any|catch|false|is|nil|super|self|Self|throw|throws|true|try)\\b"),
        MatchRule(name: "keyword.patterns", match: "\\b_\\b"),
        MatchRule(name: "keyword.pound", match: "\\b#(available|colorLiteral|column|else|elseif|endif|error|file|fileLiteral|function|if|imageLiteral|line|selector|sourceLocation|warning)\\b"),
        MatchRule(name: "keyword.particularcontexts", match: "\\b(associativity|convenience|dynamic|didSet|final|get|infix|indirect|lazy|left|mutating|none|nonmutating|optional|override|postfix|precedence|prefix|Protocol|required|right|set|Type|unowned|weak|willSet)\\b"),
        MatchRule(name: "numeric", match: "-?(?:(?:0b|0o|0x)?\\d+|\\d+\\.\\d+)"),
        MatchRule(name: "bool", match: "(true|false)"),
        MatchRule(name: "string.quoted.double", match: "\\\"(.*?)\\\"", captures: [
            Capture(),
            Capture(patterns: [
                MatchRule(name: "source.swift", match: #"\\\((.*?)\)"#, captures: [
                    Capture(),
                    Capture(patterns: [IncludeGrammarPattern(scopeName: "source.swift")])
                ])
            ])
        ]),
        BeginEndRule(name: "comment.line.double-slash.swift", begin: "//", end: "\\n", patterns: [IncludeRulePattern(include: "todo")]),
        BeginEndRule(name: "comment.block", begin: "/\\*", end: "\\*/", patterns: [IncludeRulePattern(include: "todo")])
    ],
    repository: Repository(patterns: [
        "todo": MatchRule(name: "comment.keyword.todo", match: "TODO")
    ])
)

let fontSize: CGFloat = 12
let exampleTheme: HighlightTheme = HighlightTheme(name: "basic", settings: [
    ThemeSetting(scope: "source", parentScopes: [], attributes: [
        ColorThemeAttribute(color: .exampleTextColor),
        FontThemeAttribute(font: .monospacedSystemFont(ofSize: fontSize, weight: .regular)),
        LigatureThemeAttribute(ligature: 0)
    ]),

    // Scope looks like following - // or //
    ThemeSetting(scope: "comment", parentScopes: [], attributes: [
        ColorThemeAttribute(color: NSColor(hex: "#A0D07D"))
    ]),
    ThemeSetting(scope: "punctuation.definition.comment", parentScopes: [], attributes: [
        ColorThemeAttribute(color: NSColor(hex: "#A0D07D"))
    ]),

    // Scope looks like following - ""
    ThemeSetting(scope: "punctuation.definition.string", parentScopes: [], attributes: [
        ColorThemeAttribute(color: NSColor(hex: "#FC6A5D"))
    ]),

    // Scope looks like following - 0, 1, 2, 3, 4
    ThemeSetting(scope: "constant.numeric", parentScopes: [], attributes: [
        ColorThemeAttribute(color: NSColor(hex: "#D0BF69"))
    ]),
    ThemeSetting(scope: "keyword.other.unit", parentScopes: [], attributes: [
        ColorThemeAttribute(color: NSColor(hex: "#D0BF69"))
    ]),
    ThemeSetting(scope: "support.constant", parentScopes: [], attributes: [
        ColorThemeAttribute(color: NSColor(hex: "#D0BF69"))
    ]),

    ThemeSetting(scope: "constant.language", parentScopes: [], attributes: [
        ColorThemeAttribute(color: NSColor(hex: "#FF7AB2")),
        FontThemeAttribute(font: .monospacedSystemFont(ofSize: fontSize,
                                                       weight: .bold))
    ]),
    ThemeSetting(scope: "entity.name.tag", parentScopes: [], attributes: [
        ColorThemeAttribute(color: NSColor(hex: "#FF7AB2")),
        FontThemeAttribute(font: .monospacedSystemFont(ofSize: fontSize,
                                                       weight: .bold))
    ]),
    ThemeSetting(scope: "keyword", parentScopes: [], attributes: [
        ColorThemeAttribute(color: NSColor(hex: "#FF7AB2")),
        FontThemeAttribute(font: .monospacedSystemFont(ofSize: fontSize,
                                                       weight: .bold))
    ]),
    ThemeSetting(scope: "storage.modifier.swift", parentScopes: [], attributes: [
        ColorThemeAttribute(color: NSColor(hex: "#FF7AB2")),
        FontThemeAttribute(font: .monospacedSystemFont(ofSize: fontSize,
                                                       weight: .bold))
    ]),
    ThemeSetting(scope: "storage.type", parentScopes: [], attributes: [
        ColorThemeAttribute(color: NSColor(hex: "#FF7AB2")),
        FontThemeAttribute(font: .monospacedSystemFont(ofSize: fontSize,
                                                       weight: .bold))
    ]),
    ThemeSetting(scope: "support.type.primitive", parentScopes: [], attributes: [
        ColorThemeAttribute(color: NSColor(hex: "#FF7AB2")),
        FontThemeAttribute(font: .monospacedSystemFont(ofSize: fontSize,
                                                       weight: .bold))
    ]),
    ThemeSetting(scope: "variable.language", parentScopes: [], attributes: [
        ColorThemeAttribute(color: NSColor(hex: "#FF7AB2")),
        FontThemeAttribute(font: .monospacedSystemFont(ofSize: fontSize,
                                                       weight: .bold))
    ]),

    ThemeSetting(scope: "support.type", parentScopes: [], attributes: [
        ColorThemeAttribute(color: NSColor(hex: "#ACF2E4"))
    ]),

    ThemeSetting(scope: "meta.definition.function", parentScopes: [], attributes: [
        ColorThemeAttribute(color: NSColor(hex: "#5DD8FF"))
    ]),
    ThemeSetting(scope: "meta.definition.method", parentScopes: [], attributes: [
        ColorThemeAttribute(color: NSColor(hex: "#5DD8FF"))
    ]),
    ThemeSetting(scope: "meta.method.declaration", parentScopes: [], attributes: [
        ColorThemeAttribute(color: NSColor(hex: "#5DD8FF"))
    ]),

    ThemeSetting(scope: "variable.parameter", parentScopes: [], attributes: [
        ColorThemeAttribute(color: NSColor(hex: "#48b7db"))
    ]),

    ThemeSetting(scope: "entity.name.type", parentScopes: [], attributes: [
        ColorThemeAttribute(color: NSColor(hex: "#E5CFFF"))
    ]),

    ThemeSetting(scope: "entity.other.inherited-class", parentScopes: [], attributes: [
        ColorThemeAttribute(color: NSColor(hex: "#5DD8FF"))
    ]),

    ThemeSetting(scope: "keyword.operator", parentScopes: [], attributes: [
        ColorThemeAttribute(color: NSColor(hex: "#A167E6"))
    ]),
    ThemeSetting(scope: "keyword.control.preprocessor", parentScopes: [], attributes: [
        ColorThemeAttribute(color: NSColor(hex: "#FFA14F"))
    ]),
    ThemeSetting(scope: "keyword.control.import", parentScopes: [], attributes: [
        ColorThemeAttribute(color: NSColor(hex: "#D0A8FF")),
        FontThemeAttribute(font: .monospacedSystemFont(ofSize: fontSize,
                                                       weight: .bold))
    ]),
    ThemeSetting(scope: "punctuation.definition.preprocessor", parentScopes: [], attributes: [
        ColorThemeAttribute(color: NSColor(hex: "#FFA14F"))
    ]),

    ThemeSetting(scope: "markup.underline.link", parentScopes: [], attributes: [
        ColorThemeAttribute(color: NSColor(hex: "#6699FF"))
    ]),

    ThemeSetting(scope: "meta.object-literal.key", parentScopes: [], attributes: [
        ColorThemeAttribute(color: NSColor(hex: "#72BFAE"))
    ]),

    ThemeSetting(scope: "support.constant", parentScopes: [], attributes: [
        ColorThemeAttribute(color: NSColor(hex: "#D0BF69"))
    ]),
    ThemeSetting(scope: "meta.function-call", parentScopes: [], attributes: [
        ColorThemeAttribute(color: NSColor(hex: "#CDA1FF"))
    ]),
    ThemeSetting(scope: "meta.function", parentScopes: [], attributes: [
        ColorThemeAttribute(color: NSColor(hex: "#D0A8FF"))
    ]),
    ThemeSetting(scope: "meta.function", parentScopes: [], attributes: [
        ColorThemeAttribute(color: NSColor(hex: "#D0A8FF"))
    ]),
    ThemeSetting(scope: "support.type", parentScopes: [], attributes: [
        ColorThemeAttribute(color: NSColor(hex: "#D0A8FF"))
    ]),
    ThemeSetting(scope: "meta.interface", parentScopes: [], attributes: [
        ColorThemeAttribute(color: NSColor(hex: "#D0A8FF"))
    ]),

    ThemeSetting(scope: "constant.language.boolean", parentScopes: [], attributes: [
        ColorThemeAttribute(color: NSColor(hex: "#D6C455"))
    ]),
    ThemeSetting(scope: "meta.objectliteral", parentScopes: [], attributes: [
        ColorThemeAttribute(color: NSColor(hex: "#D6C455"))
    ]),

    ThemeSetting(scope: "enum-case-clause", parentScopes: [], attributes: [
        ColorThemeAttribute(color: NSColor(hex: "#48b7db"))
    ]),
    ThemeSetting(scope: "keyword.control.branch", parentScopes: [], attributes: [
        ColorThemeAttribute(color: NSColor(hex: "#48b7db"))
    ]),

    ThemeSetting(scope: "punctuation", parentScopes: [], attributes: [
        ColorThemeAttribute(color: NSColor(hex: "#DFDFE0"))
    ]),

    ThemeSetting(scope: "support.variable", parentScopes: [], attributes: [
        ColorThemeAttribute(color: NSColor(hex: "#83C9BC"))
    ]),

    ThemeSetting(scope: "punctuation.terminator.statement", parentScopes: [], attributes: [
        ColorThemeAttribute(color: NSColor(hex: "#FFFFFF"))
    ]),

    ThemeSetting(scope: "comment.block.documentation", parentScopes: [], attributes: [
        ColorThemeAttribute(color: NSColor(hex: "#A0D07D")),
        FontThemeAttribute(font: .monospacedSystemFont(ofSize: 11, weight: .medium))
    ])

])

extension NSColor {
    public static let exampleTextColor = NSColor.init(color: .white)!

    public static let codeBackgroundColor = NSColor.init(color: .white)!
}

// swiftlint:enable line_length
