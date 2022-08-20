//
//  STTextViewController.swift
//  AuroraEditorTextView
//
//  Created by Lukas Pistrol on 24.05.22.
//

import AppKit
import SwiftUI

/// A View Controller managing and displaying a `STTextView`
public class STTextViewController: NSViewController, STTextViewDelegate {
    public var updateText: Bool = false

    internal var textView: STTextView!
    internal var rulerView: STLineNumberRulerView!

    /// Binding for the `textView`s string
    public var attrText: Binding<NSAttributedString>

    /// Binding for the `textView`s string
    public var text: Binding<String>

    /// The number of spaces to use for a `tab '\t'` character
    public var tabWidth: Int

    /// A multiplier for setting the line height. Defaults to `1.0`
    public var lineHeightMultiple: Double = 1.0

    /// The font to use in the `textView`
    public var font: NSFont

    private var keyDownEvent: Any?
    private var keyUpEvent: Any?

    // MARK: Init
    public init(text: Binding<String>,
                attrText: Binding<NSAttributedString>,
                font: NSFont,
                tabWidth: Int) {
        self.text = text
        self.attrText = attrText
        self.font = font
        self.tabWidth = tabWidth
        super.init(nibName: nil, bundle: nil)
    }

    required init(coder: NSCoder) {
        fatalError()
    }

    func setupRuler(textView: STTextView, scrollView: NSScrollView) -> STLineNumberRulerView {
        let rulerView = STLineNumberRulerView(
            textView: textView,
            scrollView: scrollView
        )
        rulerView.backgroundColor = textViewBackgroundColor()
        rulerView.textColor = .systemGray
        rulerView.separatorColor = textViewBackgroundColor()
        rulerView.baselineOffset = baselineOffset

        return rulerView
    }

    // MARK: VC Lifecycle
    override public func loadView() {
        let scrollView = STTextView.scrollableTextView()
        textView = scrollView.documentView as? STTextView

        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.hasVerticalScroller = true
        scrollView.hasHorizontalScroller = false

        rulerView = setupRuler(textView: textView, scrollView: scrollView)

        scrollView.borderType = .noBorder
        scrollView.hasVerticalRuler = true
        scrollView.hasHorizontalRuler = false
        scrollView.verticalRulerView = rulerView
        scrollView.rulersVisible = true

        textView.defaultParagraphStyle = self.paragraphStyle
        textView.font = NSFont.monospacedSystemFont(
            ofSize: 10,
            weight: .medium
        )
        textView.textColor = .textColor
        textView.backgroundColor = textViewBackgroundColor()
        textView.insertionPointWidth = 1.0
        textView.string = self.text.wrappedValue
        textView.setString(self.attrText.wrappedValue)

        textView.widthTracksTextView = true
        textView.highlightSelectedLine = true
        textView.allowsUndo = true
        textView.setupMenus()
        textView.delegate = self

        scrollView.documentView = textView
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.contentInsets = .init(top: 5, left: 0, bottom: 0, right: 0)

        self.view = scrollView

        NSLayoutConstraint.activate([
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])

        keyDownEvent = NSEvent.addLocalMonitorForEvents(matching: .keyDown) { event in
            self.keyDown(with: event)
            return event
        }

        keyUpEvent = NSEvent.addLocalMonitorForEvents(matching: .keyUp) { event in
            self.keyUp(with: event)
            return event
        }
    }

    deinit {
        Log.info("STTextView de-init'd")
        if let keyDownEvent = keyDownEvent {
            NSEvent.removeMonitor(keyDownEvent)
        }
        if let keyUpEvent = keyUpEvent {
            NSEvent.removeMonitor(keyUpEvent)
        }
    }

    override public func viewDidLoad() {
        super.viewDidLoad()
    }

    // MARK: UI

    /// A default `NSParagraphStyle` with a set `lineHeight`
    private var paragraphStyle: NSMutableParagraphStyle {
        guard let paragraph = NSParagraphStyle.default.mutableCopy() as? NSMutableParagraphStyle else {
            fatalError("Failed to get Paragraph")
        }
        paragraph.minimumLineHeight = lineHeight
        paragraph.maximumLineHeight = lineHeight
        return paragraph
    }

    /// Reloads the UI to apply changes to ``STTextViewController/font``, ``STTextViewController/theme``, ...
    internal func reloadUI() {
        Log.info("Reloading UI")
        textView?.font = font
        textView?.textColor = .textColor
        textView?.backgroundColor = textViewBackgroundColor()
//        textView?.insertionPointColor = theme.insertionPoint
//        textView?.selectionBackgroundColor = theme.selection
//        textView?.selectedLineHighlightColor = theme.lineHighlight
//
        rulerView?.backgroundColor = textViewBackgroundColor()
//        rulerView?.separatorColor = theme.invisibles
        rulerView?.baselineOffset = baselineOffset
//        setStandardAttributes() // This makes the text smaller, but flickers the screen. reloadUI is loaded after the text change.
    }

    /// Sets the standard attributes (`font`, `baselineOffset`) to the whole text
    internal func setStandardAttributes() {
        guard let textView = textView else { return }
        textView.addAttributes([
            .font: font,
            .baselineOffset: baselineOffset
        ], range: .init(0..<textView.string.count))
    }

    /// Calculated line height depending on ``STTextViewController/lineHeightMultiple``
    internal var lineHeight: Double {
        font.lineHeight * lineHeightMultiple
    }

    /// Calculated baseline offset depending on `lineHeight`.
    internal var baselineOffset: Double {
        ((self.lineHeight) - font.lineHeight) / 2
    }

    // MARK: Key Presses

    private var keyIsDown: Bool = false

    /// Handles `keyDown` events in the `textView`
    override public func keyDown(with event: NSEvent) {
        if keyIsDown { return }
        keyIsDown = true

        // handle tab insertation
        if event.specialKey == .tab {
            textView?.insertText(String(repeating: " ", count: tabWidth))
        }
    }

    /// Handles `keyUp` events in the `textView`
    override public func keyUp(with event: NSEvent) {
        keyIsDown = false
    }

    private func textViewBackgroundColor() -> NSColor {
        guard let currentTheme = ThemeModel.shared.selectedTheme,
              AppPreferencesModel.shared.preferences.theme.useThemeBackground else {
            return .textBackgroundColor
        }
        return NSColor(hex: currentTheme.editor.background.color)
    }
}
