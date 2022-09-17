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

    @Binding var text: String
    @Binding var font: NSFont
    @Binding var tabWidth: Int
    @Binding var lineHeight: Double

    /// The last text that was processed
    @State var lastText: String = ""

    /// The minimap view that the AuroraEditorTextView contains
    @State var minimapView: NSHostingView<MinimapView>?

    /// The view controller that the AuroraEditorTextView contains
    @State var viewController: NSViewControllerType?
    @State var coordinator: Coordinator?

    /// The parsed items from the text view's AttributedString
    @State var attributedTextItems: [AttributedStringItem] = []

    /// How far the text view has scrolled, in decimal (eg. 0.3 = 30%)
    @State var scrollAmount: CGFloat = 0

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

            // get the percentage of the document that has been scrolled
            let maxScroll = documentView.bounds.height - clipView.bounds.height
            let scrollPercent = min(1, max(0, clipView.bounds.origin.y / maxScroll))

            DispatchQueue.main.async {
                self.parent.scrollAmount = scrollPercent
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
