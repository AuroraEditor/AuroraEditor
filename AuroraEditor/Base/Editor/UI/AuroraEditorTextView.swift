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
        attributedTextItems: Binding<[AttributedStringItem]>,
        language: CodeLanguage?,
        themeString: String?
    ) {
        self._text = text
        self._font = font
        self._tabWidth = tabWidth
        self._lineHeight = lineHeight
        self._attributedTextItems = attributedTextItems
        self.language = language
        self.themeString = themeString
    }

    @Binding private var text: String
    @Binding private var font: NSFont
    @Binding private var tabWidth: Int
    @Binding private var lineHeight: Double
    @Binding private var attributedTextItems: [AttributedStringItem]

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
        DispatchQueue.main.async {
            let attributedText = controller.textView.attributedString()
            Log.info("Length: \(attributedText.length)")
            let length = attributedText.length

            var newAttributedTextItems: [AttributedStringItem] = []

            var position = 0
            while position < length {
                // get the attributes
                var range = NSRange()
                let attributes = attributedText.attributes(at: position, effectiveRange: &range)
                let atString = attributedText.string

                // get the line number by counting the number of newlines until the string starts
                let rangeSoFar = atString.startIndex..<atString.index(atString.startIndex, offsetBy: position)
                let stringSoFar = String(attributedText.string[rangeSoFar])
                let separatedComponents = stringSoFar.components(separatedBy: "\n")
                let newLines = separatedComponents.count - 1
                let charFromStart = separatedComponents.last?.count ?? 0

                // get the contents of the range
                let rangeContents = atString[range] ?? ""
                Log.info("range: \(range), position \(newLines),\(charFromStart), content \(rangeContents)")
                Log.info(attributes[.foregroundColor]!)

                newAttributedTextItems.append(AttributedStringItem(text: String(rangeContents),
                                                                   lineNumber: newLines,
                                                                   charactersFromStart: charFromStart,
                                                                   range: range,
                                                                   attributes: attributes))

                position = range.upperBound
            }

            attributedTextItems = newAttributedTextItems
        }
        controller.reloadUI()
        return
    }
}

public class AttributedStringItem: Identifiable, Hashable {
    public let id = UUID()

    public static func == (lhs: AttributedStringItem, rhs: AttributedStringItem) -> Bool {
        lhs.text == rhs.text &&
        lhs.lineNumber == rhs.lineNumber &&
        lhs.charactersFromStart == rhs.charactersFromStart &&
        lhs.range == rhs.range
        // attributes are a bit hard to compare so they're not included
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(text)
        hasher.combine(lineNumber)
        hasher.combine(charactersFromStart)
        hasher.combine(range)
    }

    var text: String
    var lineNumber: Int
    var charactersFromStart: Int
    var range: NSRange
    var attributes: [NSAttributedString.Key: Any]

    init(text: String,
         lineNumber: Int,
         charactersFromStart: Int,
         range: NSRange,
         attributes: [NSAttributedString.Key: Any]) {
        self.text = text
        self.lineNumber = lineNumber
        self.charactersFromStart = charactersFromStart
        self.range = range
        self.attributes = attributes
    }
}
