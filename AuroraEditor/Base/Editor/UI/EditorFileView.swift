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
    ThemeSetting(scope: "comment", parentScopes: [], attributes: [
        ColorThemeAttribute(color: .systemGreen)
    ]),
    ThemeSetting(scope: "constant", parentScopes: [], attributes: [
        ColorThemeAttribute(color: .cyan)
    ]),
    ThemeSetting(scope: "entity", parentScopes: [], attributes: [
        ColorThemeAttribute(color: .green)
    ]),
    ThemeSetting(scope: "invalid", parentScopes: [], attributes: []),
    ThemeSetting(scope: "keyword", parentScopes: [], attributes: [
        ColorThemeAttribute(color: .systemBlue)
    ]),
//    ThemeSetting(scope: "markup", parentScopes: [], attributes: []),
    ThemeSetting(scope: "storage", parentScopes: [], attributes: []),
    ThemeSetting(scope: "string", parentScopes: [], attributes: [
        ColorThemeAttribute(color: .systemRed)
    ]),
    ThemeSetting(scope: "string.content", parentScopes: [], attributes: [
        ColorThemeAttribute(color: .systemOrange)
    ]),
    ThemeSetting(scope: "support", parentScopes: [], attributes: []),
    ThemeSetting(scope: "variable", parentScopes: [], attributes: [
        ColorThemeAttribute(color: .yellow)
    ]),
    ThemeSetting(scope: "source", parentScopes: [], attributes: [
        ColorThemeAttribute(color: .exampleTextColor),
        FontThemeAttribute(font: .monospacedSystemFont(ofSize: fontSize, weight: .regular)),
        LigatureThemeAttribute(ligature: 0),
        FirstLineHeadIndentThemeAttribute(value: 48),
        TailIndentThemeAttribute(value: -30),
        HeadIndentThemeAttribute(value: 48)
    ]),
    ThemeSetting(scope: "comment.keyword", parentScopes: [], attributes: [
        ColorThemeAttribute(color: .systemTeal)
    ]),
//    ThemeSetting(scope: "markup.bold", parentScopes: [], attributes: [
//        BoldThemeAttribute()
//    ]),
//    ThemeSetting(scope: "markup.italic", parentScopes: [], attributes: [
//        ItalicThemeAttribute()
//    ]),
//    ThemeSetting(scope: "markup.mono", parentScopes: [], attributes: [
//        BackgroundColorThemeAttribute(color: .gray, roundingStyle: .quarter)
//    ]),
    ThemeSetting(scope: "action", parentScopes: [], attributes: [
        ActionThemeAttribute(actionId: "test", handler: { str, range  in
            Log.info("string: \(str), range \(range)")
        }),
        UnderlineThemeAttribute(color: .clear),
        BackgroundColorThemeAttribute(color: .systemPurple, roundingStyle: .full)
    ]),
    ThemeSetting(scope: "action.syntax", parentScopes: [], attributes: [],
                 inSelectionAttributes: [HiddenThemeAttribute(hidden: false)],
                 outSelectionAttributes: [HiddenThemeAttribute()]
                ),
    ThemeSetting(scope: "hidden", parentScopes: [], attributes: [], inSelectionAttributes: [
        HiddenThemeAttribute(hidden: false)
    ], outSelectionAttributes: [
        HiddenThemeAttribute(hidden: true)
    ])
//    ThemeSetting(scope: "markup.heading.1", parentScopes: [], attributes: [
//        FontThemeAttribute(font: .monospacedSystemFont(ofSize: fontSize * 2, weight: .regular)),
//        FirstLineHeadIndentThemeAttribute(value: 18)
//    ]),
//    ThemeSetting(scope: "markup.heading.2", parentScopes: [], attributes: [
//        FontThemeAttribute(font: .monospacedSystemFont(ofSize: fontSize * 1.6, weight: .regular)),
//        FirstLineHeadIndentThemeAttribute(value: 8)
//    ]),
//    ThemeSetting(scope: "markup.heading.3", parentScopes: [], attributes: [
//        FontThemeAttribute(font: .monospacedSystemFont(ofSize: fontSize * 1.3, weight: .regular)),
//        FirstLineHeadIndentThemeAttribute(value: 0)
//    ]),
//    ThemeSetting(scope: "markup.center", parentScopes: [], attributes: [
//        BackgroundColorThemeAttribute(color: Color.gray, roundingStyle: .quarter, coloringStyle: .line)
//    ]),
//    ThemeSetting(scope: "markup.center.content", parentScopes: [], attributes: [
//        TextAlignmentThemeAttribute(value: .center)
//    ]),
//    ThemeSetting(
//        scope: "markdown.link",
//        parentScopes: [],
//        attributes: [],
//        inSelectionAttributes: [
//            HiddenThemeAttribute(hidden: false)
//        ],
//        outSelectionAttributes: [
//            HiddenThemeAttribute(hidden: true)
//        ]
//    ),
//    ThemeSetting(
//        scope: "markdown.link.name",
//        parentScopes: [],
//        attributes: [
//            HiddenThemeAttribute(hidden: false)
//        ],
//        outSelectionAttributes: [
//            HiddenThemeAttribute(hidden: false)
//        ]
//    ),
//    ThemeSetting(
//        scope: "markdown.link.link",
//        parentScopes: [],
//        attributes: []
//    ),
//    ThemeSetting(
//        scope: "markup.syntax",
//        parentScopes: [],
//        attributes: [],
//        inSelectionAttributes: [
//            HiddenThemeAttribute(hidden: false)
//        ],
//        outSelectionAttributes: [
//            HiddenThemeAttribute(hidden: true)
//        ]
//    ),
//    ThemeSetting(scope: "markup.code.block", parentScopes: [], attributes: [
//        BackgroundColorThemeAttribute(color: .codeBackgroundColor, roundingStyle: .full, coloringStyle: .line)
//    ])
])

extension NSColor {
    public static let exampleTextColor = NSColor.init(color: .white)!

    public static let codeBackgroundColor = NSColor.init(color: .white)!
}

// swiftlint:enable line_length
