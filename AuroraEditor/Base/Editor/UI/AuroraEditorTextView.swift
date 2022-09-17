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
public struct AuroraEditorTextView: NSViewControllerRepresentable, Equatable {
    public static func == (lhs: AuroraEditorTextView, rhs: AuroraEditorTextView) -> Bool {
        lhs.viewController == rhs.viewController
    }

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
    @State private var attributedTextItems: [AttributedStringItem] = []
    @State private var scrollAmount: CGFloat = 0

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
        updateProperties(controller: controller)
        return controller
    }

    @State private var lastText: String = ""
    @State private var minimapView: NSHostingView<MinimapView>?
    @State var viewController: NSViewControllerType?
    @State var coordinator: Coordinator?

    public func updateNSViewController(_ controller: NSViewControllerType, context: Context) {
        controller.font = font
        controller.tabWidth = tabWidth
        controller.lineHeightMultiple = lineHeight

        let attributedText = controller.textView.attributedString()
        if attributedText.string != lastText {
            DispatchQueue.main.async {
                lastText = attributedText.string
                updateTextItems(attributedText: attributedText)
                addMinimapView(to: controller)
            }
        } else if viewController != controller {
            minimapView?.removeFromSuperview()
            addMinimapView(to: controller)
        }

        updateProperties(controller: controller)
        controller.reloadUI()
        return
    }

    /// Adds a minimap view to a controller, creating one if it doesn't exist
    /// - Parameters:
    ///   - controller: The controller to add the minimap view to
    ///   - overrideMinimap: The minimap to add. If nil, it tries to look for a saved one.
    ///   If there are no saved minimaps, it creates one.
    func addMinimapView(to controller: NSViewControllerType,
                        minimapView overrideMinimap: NSHostingView<MinimapView>? = nil) {
        if let minimapView = overrideMinimap ?? self.minimapView {
            if let scrollContent = controller.textView.scrollView {
                minimapView.frame = NSRect(x: scrollContent.frame.width-150,
                                            y: 0,
                                            width: 150,
                                            height: scrollContent.frame.height)
                scrollContent.addSubview(minimapView)
            }
        } else {
            let minimapView = NSHostingView(rootView: MinimapView(attributedTextItems: $attributedTextItems,
                                                                  scrollAmount: $scrollAmount))
            DispatchQueue.main.async {
                self.minimapView = minimapView
            }
            addMinimapView(to: controller, minimapView: minimapView)
        }
    }

    /// Takes an attributed string and turns it into an array of ``AttributedStringItem``s
    /// - Parameter attributedText: The attributed string to parse
    func updateTextItems(attributedText: NSAttributedString) {
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
            var newLines = separatedComponents.count - 1
            var charFromStart = separatedComponents.last?.count ?? 0

            // get the contents of the range
            let rangeContents = atString[range] ?? ""

            // split by \n characters and spaces
            let lines = String(rangeContents).components(separatedBy: "\n")

            for line in lines {
                let words = line.components(separatedBy: " ")
                for word in words {
                    if !word.isEmpty {
                        newAttributedTextItems.append(AttributedStringItem(text: word,
                                                                           lineNumber: newLines,
                                                                           charactersFromStart: charFromStart,
                                                                           range: range,
                                                                           attributes: attributes))
                    }

                    // modify the charactersFromStart for each word
                    charFromStart += word.count + 1
                }

                // modify the line number and charactersFromStart for each line
                charFromStart = 0
                newLines += 1
            }

            position = range.upperBound
        }

        attributedTextItems = newAttributedTextItems
    }

    public class Coordinator: NSObject {
        let parent: AuroraEditorTextView
        init(parent: AuroraEditorTextView) {
            self.parent = parent
            super.init()

            if let scrollView = parent.viewController?.textView.scrollView {
                configureScrollView(scrollView: scrollView)
            }
        }

        private func configureScrollView(scrollView: NSScrollView) {
            Log.info("Config scroll view")
            scrollView.contentView.postsBoundsChangedNotifications = true
            NotificationCenter.default.addObserver(self, selector: #selector(contentViewDidChangeBounds),
                                                   name: NSView.boundsDidChangeNotification,
                                                   object: scrollView.contentView)
        }

        @objc
        func contentViewDidChangeBounds(_ notification: Notification) {
            guard let scrollView = parent.viewController?.textView.scrollView,
                  let documentView = scrollView.documentView else { return }

            let clipView = scrollView.contentView

            Log.info("Bounds changed to \(clipView.bounds.origin.y)")
            let maxScroll = documentView.bounds.height - clipView.bounds.height

            DispatchQueue.main.async {
                self.parent.scrollAmount = clipView.bounds.origin.y / maxScroll
            }
        }
    }

    public func makeCoordinator() -> Coordinator {
        let coordinator = Coordinator(parent: self)
        return coordinator
    }

    private func updateProperties(controller: NSViewControllerType) {
        DispatchQueue.main.async {
            if self.viewController != controller {
                self.viewController = controller
                self.coordinator = makeCoordinator()
            } else if self.coordinator == nil {
                self.coordinator = makeCoordinator()
            }
        }
    }
}

/// A class that manages a single minimap attributed string item. Includes data
/// like the line number, length, and characters from start.
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
