//
//  Editor.swift
//  
//
//  Created by Matthew Davidson on 4/12/19.
//

import Foundation
import EditorCore

// MARK: - iOS
#if os(iOS)
import UIKit

public class Editor: NSObject {

    public typealias TokenHandler = ([(String, NSRange)]) -> Void

    var tokenHandlers = [String: [TokenHandler]]()

    let textView: EditorTextView

    var _parser: Parser

    var _grammar: Grammar

    var _theme: Theme

    var parser: Parser {
        _parser
    }

    var grammar: Grammar {
        _grammar
    }

    var theme: Theme {
        _theme
    }

    private var fixedGlyphProperties = [NSRange: [NSLayoutManager.GlyphProperty]]()
    private var shouldResetGlyphProperties = true

    /// - param textView: The text view which should be observed and highlighted.
    /// - param notificationCenter: The notification center to subscribe in.
    ///   A testing seam. Defaults to `NotificationCenter.default`.
    public init(
        textView: EditorTextView,
        parser: Parser,
        baseGrammar: Grammar,
        theme: Theme,
        notificationCenter: NotificationCenter = .default)
    {
        self.textView = textView
        self._parser = parser
        self._grammar = baseGrammar
        self._theme = theme
        super.init()

        textView.delegate = self
        textView.layoutManager.delegate = self
        textView.replace(parser: parser, baseGrammar: baseGrammar, theme: theme)
        textView.textContainerInset = UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20)
        // Set the type attributes to base scope. This is important for the line height of the empty final line in the document and the look of an initially empty document.
        textView.typingAttributes = baseGrammar.baseAttributes(forTheme: theme)
        didHighlightSyntax(textView: textView)
    }

    public func replace(parser: Parser, baseGrammar: Grammar, theme: Theme) {
        _parser = parser
        _grammar = baseGrammar
        _theme = theme

        textView.replace(parser: parser, baseGrammar: baseGrammar, theme: theme)
        textView.typingAttributes = baseGrammar.baseAttributes(forTheme: theme)
        didHighlightSyntax(textView: textView)
    }

    private func didHighlightSyntax(textView: EditorTextView) {
        guard let storage = textView.textStorage as? EditorTextStorage else {
            return
        }

        // Layout the view for the invalidated visible range.
        // Get the visible range
        let visibleRect = Rect(x: 0, y: 0, width: textView.visibleSize.width, height: textView.visibleSize.height)
        let visibleRange = textView.layoutManager.glyphRange(forBoundingRect: visibleRect, in: textView.textContainer)

        // Get the intersection of the invalidated range and visible range.
        // If there is no intersection, no display needed.
        if let visibleInvalid = visibleRange.intersection(storage.lastProcessedRange) {
            // Try to get the bounding rect of the invalid range and only re-render it, otherwise re-render the entire text view.
            if let rect = textView.boundingRect(forCharacterRange: visibleInvalid) {
                textView.setNeedsDisplay(rect)
            }
            else {
                textView.setNeedsDisplay()
            }
        }

        callTokenHandlers(storage: storage)

        // Check EOF
        if !storage.string.isEmpty && storage.string.last != "\n" {
            let prev = textView.selectedRange
            storage.append(NSAttributedString(string: "\n"))
            textView.selectedRange = prev
        }
    }
}

extension Editor: UITextViewDelegate {

    public func textViewDidChange(_ textView: UITextView) {
        guard let editorTextView = textView as? EditorTextView else {
            return
        }

        didHighlightSyntax(textView: editorTextView)
    }

    public func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange, interaction: UITextItemInteraction) -> Bool {

        var linkRange = NSRange(location: 0, length: 0)

        guard let handler = textView.attributedText.attribute(ActionThemeAttribute.HandlerKey, at: characterRange.location, effectiveRange: &linkRange) as? ActionThemeAttribute.Handler,
            linkRange.length > 0 else {
            return true
        }

        print(linkRange)
        let str = (textView.text as NSString).substring(with: linkRange)

        handler(str, linkRange)

        return false
    }

    public func textViewDidChangeSelection(_ textView: UITextView) {
        guard let editorTextView = textView as? EditorTextView,
            let storage = textView.textStorage as? EditorTextStorage else {
            return
        }

        if !storage.isProcessingEditing {
            let rangeChanged = storage.updateSelectedRanges([editorTextView.selectedRange])

            // If there are any lines that changed
            if rangeChanged.location != NSNotFound {
                // And re-display. This is important for rounded highlighting for full lines to ensure that rounding is not applied in the middle.
                if let rect = editorTextView.boundingRect(forCharacterRange: rangeChanged) {
                    editorTextView.setNeedsDisplay(rect)
                }
                else {
                    editorTextView.setNeedsDisplay()
                }
            }
        }
    }
}

// MARK: - macOS
#elseif os(macOS)
import Cocoa

public class Editor: NSObject {

    public typealias TokenHandler = ([(String, NSRange)]) -> Void

    var tokenHandlers = [String: [TokenHandler]]()

    let textView: EditorTextView

    var _parser: Parser

    var _grammar: Grammar

    var _theme: Theme

    var parser: Parser {
        _parser
    }

    var grammar: Grammar {
        _grammar
    }

    var theme: Theme {
        _theme
    }

    private var fixedGlyphProperties = [NSRange: [NSLayoutManager.GlyphProperty]]()
    private var shouldResetGlyphProperties = true

    /// - param textView: The text view which should be observed and highlighted.
    /// - param notificationCenter: The notification center to subscribe in.
    ///   A testing seam. Defaults to `NotificationCenter.default`.
    public init(
        textView: EditorTextView,
        parser: Parser,
        baseGrammar: Grammar,
        theme: Theme,
        notificationCenter: NotificationCenter = .default)
    {
        self.textView = textView
        self._parser = parser
        self._grammar = baseGrammar
        self._theme = theme
        super.init()

        textView.delegate = self
        textView.layoutManager?.delegate = self
        textView.replace(parser: parser, baseGrammar: baseGrammar, theme: theme)
        textView.textContainerInset = NSSize(width: 20, height: 20)
        // Set the type attributes to base scope. This is important for the line height of the empty final line in the document and the look of an initially empty document.
        textView.typingAttributes = baseGrammar.baseAttributes(forTheme: theme)
        didHighlightSyntax(textView: textView)

        notificationCenter.addObserver(self, selector: #selector(textViewDidChange(_:)), name: NSText.didChangeNotification, object: textView)
    }

    public func replace(parser: Parser, baseGrammar: Grammar, theme: Theme) {
        _parser = parser
        _grammar = baseGrammar
        _theme = theme

        textView.replace(parser: parser, baseGrammar: baseGrammar, theme: theme)
        textView.typingAttributes = baseGrammar.baseAttributes(forTheme: theme)
        didHighlightSyntax(textView: textView)
    }

    @objc func textViewDidChange(_ notification: Notification) {
        didHighlightSyntax(textView: textView)
    }

    private func didHighlightSyntax(textView: EditorTextView) {
        guard let storage = textView.textStorage as? EditorTextStorage,
            let layoutManager = textView.layoutManager,
            let textContainer = textView.textContainer else {
            return
        }

        // Layout the view for the invalidated visible range.
        // Get the visible range
        let visibleRange = layoutManager.glyphRange(forBoundingRect: textView.visibleRect, in: textContainer)

        // Get the intersection of the invalidated range and visible range.
        // If there is no intersection, no display needed.
        if let visibleInvalid = visibleRange.intersection(storage.lastProcessedRange) {
            // Try to get the bounding rect of the invalid range and only re-render it, otherwise re-render the entire text view.
            if let rect = textView.boundingRect(forCharacterRange: visibleInvalid) {
                textView.setNeedsDisplay(rect, avoidAdditionalLayout: false)
            }
            else {
                textView.needsDisplay = true
            }
        }

        callTokenHandlers(storage: storage)

        // Check EOF
        if !storage.string.isEmpty && storage.string.last != "\n" {
            let prev = textView.selectedRanges
            storage.append(NSAttributedString(string: "\n"))
            textView.selectedRanges = prev
        }
    }
}

extension Editor: NSTextViewDelegate {

    public func textView(_ textView: NSTextView, clickedOnLink link: Any, at charIndex: Int) -> Bool {
        var linkRange = NSRange(location: 0, length: 0)

        guard let id = link as? String,
            let handler = textView.attributedString().attribute(ActionThemeAttribute.HandlerKey, at: charIndex, effectiveRange: &linkRange) as? ActionThemeAttribute.Handler,
            linkRange.length > 0 else {
            return false
        }

        print(linkRange)
        let str = (textView.string as NSString).substring(with: linkRange)

        handler(str, linkRange)

        return true
    }

    public func textViewDidChangeSelection(_ notification: Notification) {
        guard let textView = notification.object as? EditorTextView,
            let storage = textView.textStorage as? EditorTextStorage else {
            return
        }

        if !storage.isProcessingEditing {
            let rangeChanged = storage.updateSelectedRanges(textView.selectedRanges.map{$0.rangeValue})

            // If there are any lines that changed
            if rangeChanged.location != NSNotFound {
                // And re-display. This is important for rounded highlighting for full lines to ensure that rounding is not applied in the middle.
                if let rect = textView.boundingRect(forCharacterRange: rangeChanged) {
                    textView.setNeedsDisplay(rect, avoidAdditionalLayout: false)
                }
                else {
                    textView.needsDisplay = true
                }
            }
        }
    }
}

#endif

// MARK: - Common
extension Editor: NSLayoutManagerDelegate {

    private func resetGlyphPropertiesIfNeeded(textStorage: NSTextStorage) {
        guard shouldResetGlyphProperties else {
            return
        }

        fixedGlyphProperties.removeAll()
        shouldResetGlyphProperties = false
    }

    // MARK: NSLayoutManagerDelegate
    public func layoutManager(_: NSLayoutManager, didCompleteLayoutFor _: NSTextContainer?, atEnd layoutFinishedFlag: Bool) {
        // The layout pass is done, reset the glyph properties on the next glyph generation pass.
        shouldResetGlyphProperties = layoutFinishedFlag
    }

    // Inspiration from: https://stackoverflow.com/a/57697139
    public func layoutManager(_ layoutManager: NSLayoutManager, shouldGenerateGlyphs glyphs: UnsafePointer<CGGlyph>, properties props: UnsafePointer<NSLayoutManager.GlyphProperty>, characterIndexes charIndexes: UnsafePointer<Int>, font aFont: Font, forGlyphRange glyphRange: NSRange) -> Int {

        guard let storage = layoutManager.textStorage else {
            return 0
        }

        fixedGlyphProperties[glyphRange] = [NSLayoutManager.GlyphProperty]()

        // Calculate the character range
        let firstCharIndex = charIndexes[0]
        let lastCharIndex = charIndexes[glyphRange.length - 1]
        let charactersRange = NSRange(location: firstCharIndex, length: lastCharIndex - firstCharIndex + 1)

        // Find the ranges that need to be hidden
        var hiddenRanges = [NSRange]()
        storage.enumerateAttribute(HiddenThemeAttribute.Key, in: charactersRange, using: { value, range, stop in
            guard value as? Bool == true else {
                return
            }

            hiddenRanges.append(range)
        })

        // Set the glyph properties
        for i in 0 ..< glyphRange.length {
            let characterIndex = charIndexes[i]
            var glyphProperties = props[i]

            let matchingHiddenRanges = hiddenRanges.filter { NSLocationInRange(characterIndex, $0) }
            if !matchingHiddenRanges.isEmpty {
                // Note: .null is the value that makes sense here, however it causes strange indentation issues when the first glyph on the line is hidden.
                glyphProperties = .controlCharacter
            }

            fixedGlyphProperties[glyphRange]!.append(glyphProperties)
        }

        let modifiedGlyphPropertiesPointer = UnsafePointer<NSLayoutManager.GlyphProperty>(fixedGlyphProperties[glyphRange]!)

        // Set the new glyphs
        layoutManager.setGlyphs(glyphs, properties: modifiedGlyphPropertiesPointer, characterIndexes: charIndexes, font: aFont, forGlyphRange: glyphRange)

        return glyphRange.length
    }
}

extension Editor {

    public func subscribe(toToken scope: String, handler: @escaping TokenHandler) {
        if tokenHandlers.keys.contains(scope) {
            tokenHandlers[scope]?.append(handler)
        }
        else {
            tokenHandlers[scope] = [handler]
        }
        // Make first call
        guard let storage = textView.textStorage as? EditorTextStorage else {
            return
        }
        handler(storage.getTokens(forScope: scope))
    }

    private func callTokenHandlers(storage: EditorTextStorage) {
        for tokenHandlers in self.tokenHandlers {
            let tokens = storage.getTokens(forScope: tokenHandlers.key)
            for handler in tokenHandlers.value {
                handler(tokens)
            }
        }
    }
}
