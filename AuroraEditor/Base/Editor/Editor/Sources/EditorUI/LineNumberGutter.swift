//
//  LineNumberGutter.swift
//  
//
//  Created by Matthew Davidson on 13/12/19.
//

import Foundation

#if os(iOS)
import UIKit


#elseif os(macOS)

import Cocoa

/// A line number ruler view.
///
/// Adapted from: https://github.com/raphaelhanneken/line-number-text-view
public class LineNumberGutter: NSRulerView {

    public var font: NSFont = NSFont.monospacedDigitSystemFont(ofSize: 12, weight: .light)

    /// Holds the background color.
    internal var backgroundColor: NSColor {
        didSet {
            self.needsDisplay = true
        }
    }

    /// Holds the text color.
    internal var foregroundColor: NSColor {
        didSet {
            self.needsDisplay = true
        }
    }

    internal var currentLineForegroundColor: NSColor {
        didSet {
            self.needsDisplay = true
        }
    }

    ///  Initializes a LineNumberGutter with the given attributes.
    ///
    ///  - parameter textView:        NSTextView to attach the LineNumberGutter to.
    ///  - parameter foregroundColor: Defines the foreground color.
    ///  - parameter backgroundColor: Defines the background color.
    ///
    ///  - returns: An initialized LineNumberGutter object.
    public init(
        withTextView textView: NSTextView,
        foregroundColor: NSColor = .secondaryLabelColor,
        backgroundColor: NSColor = .textBackgroundColor,
        currentLineForegroundColor: NSColor = .selectedTextColor,
        ruleThickness: CGFloat = 40
    ) {
        // Set the color preferences.
        self.backgroundColor = backgroundColor
        self.foregroundColor = foregroundColor
        self.currentLineForegroundColor = currentLineForegroundColor

        // Make sure everything's set up properly before initializing properties.
        super.init(scrollView: textView.enclosingScrollView, orientation: .verticalRuler)

        // Set the rulers clientView to the supplied textview.
        self.clientView = textView
        // Define the ruler's width.
        self.ruleThickness = ruleThickness
    }

    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    ///  Draws the line numbers.
    ///
    ///  - parameter rect: NSRect to draw the gutter view in.
    override public func drawHashMarksAndLabels(in rect: NSRect) {
        // Set the current background color...
        self.backgroundColor.set()
        // ...and fill the given rect.
        rect.fill()

        // Unwrap the clientView, the layoutManager and the textContainer, since we'll
        // them sooner or later.
        guard let textView      = self.clientView as? NSTextView,
              let layoutManager = textView.layoutManager,
              let textContainer = textView.textContainer else {
            return
        }
        let content = textView.string

        // Get the range of the currently visible glyphs.
        let visibleGlyphsRange = layoutManager.glyphRange(forBoundingRect: textView.visibleRect, in: textContainer)

        // Check how many lines are out of the current bounding rect.
        var lineNumber: Int = 1
        do {
            // Define a regular expression to find line breaks.
            let newlineRegex = try NSRegularExpression(pattern: "\n", options: [])
            // Check how many lines are out of view; From the glyph at index 0
            // to the first glyph in the visible rect.
            lineNumber += newlineRegex.numberOfMatches(in: content, options: [], range: NSMakeRange(0, visibleGlyphsRange.location))
        } catch {
            return
        }

        // Get the lines currently selected.
        let currentLines = getVisibileSelectedLines(content: content, selectedRanges: textView.selectedRanges.map{$0.rangeValue}, visibleRange: visibleGlyphsRange, firstLineNumber: lineNumber)


        // Get the index of the first glyph in the visible rect, as starting point...
        var firstGlyphOfLineIndex = visibleGlyphsRange.location

        // ...then loop through all visible glyphs, line by line.
        while firstGlyphOfLineIndex < NSMaxRange(visibleGlyphsRange) {
            // Get the character range of the line we're currently in.
            let charRangeOfLine  = (content as NSString).lineRange(for: NSRange(location: layoutManager.characterIndexForGlyph(at: firstGlyphOfLineIndex), length: 0))
            // Get the glyph range of the line we're currently in.
            let glyphRangeOfLine = layoutManager.glyphRange(forCharacterRange: charRangeOfLine, actualCharacterRange: nil)

            var firstGlyphOfRowIndex = firstGlyphOfLineIndex
            var lineWrapCount        = 0

            // Loop through all rows (soft wraps) of the current line.
            while firstGlyphOfRowIndex < NSMaxRange(glyphRangeOfLine) {
                // The effective range of glyphs within the current line.
                var effectiveRange = NSRange(location: 0, length: 0)

                // Get the rect for the current line fragment.
                let lineRect = layoutManager.lineFragmentRect(forGlyphAt: firstGlyphOfRowIndex, effectiveRange: &effectiveRange, withoutAdditionalLayout: true)

                // Draw the current line number;
                // When lineWrapCount > 0 the current line spans multiple rows.
                if lineWrapCount == 0 {
                    self.drawLineNumber(
                        num: lineNumber,
                        atY: lineRect.minY + textView.textContainerInset.height,
                        maxHeight: lineRect.height,
                        isCurrentLine: currentLines.contains(lineNumber)
                    )
                }
                else {
                    break
                }

                // Move to the next row.
                firstGlyphOfRowIndex = NSMaxRange(effectiveRange)
                lineWrapCount += 1
            }

            // Move to the next line.
            firstGlyphOfLineIndex = NSMaxRange(glyphRangeOfLine)
            lineNumber += 1
        }

        // Draw another line number for the extra line fragment.
        if let _ = layoutManager.extraLineFragmentTextContainer {
            self.drawLineNumber(
                num: lineNumber,
                atY: layoutManager.extraLineFragmentRect.minY + textView.textContainerInset.height,
                maxHeight: layoutManager.extraLineFragmentRect.height,
                isCurrentLine: visibleGlyphsRange.upperBound == textView.selectedRanges.last?.rangeValue.upperBound
            )
        }
    }

    /// Gets the lines currently selected out of the visible range.
    func getVisibileSelectedLines(content: String, selectedRanges: [NSRange], visibleRange: NSRange, firstLineNumber: Int) -> [Int] {
        // Get a list of the visible lines. Including newlines!
        let startI = content.utf16.index(content.utf16.startIndex, offsetBy: visibleRange.location)
        let endI = content.utf16.index(content.utf16.startIndex, offsetBy: visibleRange.upperBound)
        let visLines = content[startI..<endI].split(separator: "\n", omittingEmptySubsequences: false).map{$0 + "\n"}

        // Loop through each visible line.
        var loc = visibleRange.location
        var currentLines = [Int]()
        for (i, line) in visLines.enumerated() {
            // See if the any of the selected ranges has an intersection with the line, if so then this line is part of the selection.
            let lineRange = NSRange(location: loc, length: line.utf16.count)
            if selectedRanges.filter({
                $0.intersection(lineRange) != nil
            }).count > 0 {
                currentLines.append(i + firstLineNumber)
            }
            loc += line.utf16.count
        }
        return currentLines
    }


    func drawLineNumber(num: Int, atY yPos: CGFloat, maxHeight: CGFloat, isCurrentLine: Bool = false) {
        // Unwrap the text view.
        guard let textView = self.clientView as? NSTextView else {
            return
        }

        // Define attributes for the attributed string.
        let attrs = [NSAttributedString.Key.font: font, NSAttributedString.Key.foregroundColor: isCurrentLine ? self.currentLineForegroundColor : self.foregroundColor]

        // Define the attributed string.
        let attributedString = NSAttributedString(string: "\(num)", attributes: attrs)

        // Get the NSZeroPoint from the text view.
        let relativePoint = self.convert(NSZeroPoint, from: textView)

        // Calculate the x position, within the gutter.
        let xPosition = ruleThickness - (attributedString.size().width + 5)

        // Center it vertically
        let yPosition = relativePoint.y + yPos + (maxHeight - attributedString.size().height) / 2

        // Draw the attributed string to the calculated point.
        attributedString.draw(at: NSPoint(x: xPosition, y: yPosition))
    }
}

#endif
