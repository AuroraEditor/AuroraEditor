//
//  AuroraEditorTextView.swift
//  AuroraEditorTextView
//
//  Created by Lukas Pistrol on 24.05.22.
//

import SwiftUI

class AEHighlight {
    @ObservedObject
    var sharedCFG: SharedObjects = .shared

    public func highlight(
        code: String,
        language: CodeLanguage? = CodeLanguage.default,
        themeString: String? = "") -> NSAttributedString {
        let highlightr = Highlightr()

        if let themeString = themeString {
            highlightr?.setTheme(theme: .init(themeString: themeString))
        } else {
            highlightr?.setTheme(to: "xcode")
        }

        if let highlightr = highlightr,
           let string = highlightr.highlight(code,
            as: language?.id.rawValue,
            fastRender: true
           ) {
            return string
        }

        return NSAttributedString(string: code)
    }
}
/// A `SwiftUI` wrapper for a ``STTextViewController``.
public struct AuroraEditorTextView: NSViewControllerRepresentable {
    var language: CodeLanguage? = CodeLanguage.default
    var themeString: String?

    /// Initializes a Text Editor
    /// - Parameters:
    ///   - text: The text content
    ///   - language: The language for syntax highlighting
    ///   - theme: The theme for syntax highlighting
    ///   - font: The default font
    ///   - tabWidth: The tab width
    ///   - lineHeight: The line height multiplier (e.g. `1.2`)
    public init(
        _ text: Binding<String>,
        font: Binding<NSFont>,
        tabWidth: Binding<Int>,
        lineHeight: Binding<Double>,
        language: CodeLanguage?,
        themeString: String?
    ) {
        self._text = text
        self._font = font
        self._tabWidth = tabWidth
        self._lineHeight = lineHeight
        self.language = language
        self.themeString = themeString
    }

    @Binding private var text: String
    @Binding private var font: NSFont
    @Binding private var tabWidth: Int
    @Binding private var lineHeight: Double

    public typealias NSViewControllerType = STTextViewController

    public func makeNSViewController(context: Context) -> NSViewControllerType {
        let controller = NSViewControllerType(
            text: $text,
            attrText: .constant(
                AEHighlight().highlight(
                    code: text,
                    language: language,
                    themeString: themeString
                )
            ),
            font: font,
            tabWidth: tabWidth
        )
        controller.lineHeightMultiple = lineHeight
        return controller
    }

    public func updateNSViewController(_ controller: NSViewControllerType, context: Context) {
        controller.font = font
        controller.tabWidth = tabWidth
        controller.lineHeightMultiple = lineHeight
        controller.reloadUI()
        return
    }
}
