//
//  GutterSharedCode.swift
//  Aurora Editor
//
//  Created by Nanashi Li on 2022/09/24.
//

import AppKit

// MARK: - Shared code
extension GutterView {

    var optLayoutManager: NSLayoutManager? { textView.optLayoutManager }
    var optTextContainer: NSTextContainer? { textView.optTextContainer }
    var optLineMap: LineMap<LineInfo>? { textView.optLineMap }

    // MARK: - Gutter notifications

    /// Notifies the gutter view that a range of characters will be redrawn by the layout manager or that there are
    /// selection status changes; thus, the corresponding gutter area might require redrawing, too.
    ///
    /// - Parameters:
    ///   - charRange: The invalidated range of characters. It will be trimmed to be within the valid character range of
    ///     the underlying text storage.
    ///
    /// We invalidate the area corresponding to entire paragraphs. This makes a difference in the presence of line
    /// breaks.
    func invalidateGutter(forCharRange charRange: NSRange) {

        guard let layoutManager = optLayoutManager,
              let textContainer = optTextContainer
        else { return }

        let string = textView.text as NSString

        let textRect: CGRect

        if charRange.location >= string.length {    // special case: insertion point on trailing empty line
                                                    // or beyond the end of the string (just deleted last trailing line)
            let fragRect = layoutManager.extraLineFragmentRect
            textRect = CGRect(x: fragRect.minX, y: fragRect.minY, width: fragRect.width, height: fragRect.height * 2)
        } else {
            // We call `paragraphRange(for:_)` safely by boxing `charRange` to the allowed range.
            let extendedCharRange = string.paragraphRange(
                for: NSIntersectionRange(charRange, NSRange(location: 0, length: string.length))
            )
            let glyphRange = layoutManager.glyphRange(forCharacterRange: extendedCharRange,
                                                      actualCharacterRange: nil)
            textRect = layoutManager.boundingRect(forGlyphRange: glyphRange, in: textContainer)
        }

        setNeedsDisplay(gutterRectFrom(textRect: textRect))
    }

    /// Trigger drawing any pending gutter draw rectangle.
    func layoutFinished() {
        setNeedsDisplay(gutterRectFrom(textRect: self.frame))
    }

    // MARK: - Gutter drawing

    override func draw(_ rect: CGRect) {
        guard let layoutManager = optLayoutManager,
              let textContainer = optTextContainer,
              let lineMap = optLineMap
        else { return }

        drawMinimapGutterView(rect, layoutManager, lineMap, textContainer)

        // all functionality below is not for the minimap gutter, so if it is a minimap gutter then stop here.
        guard !isMinimapGutter else { return }

        drawGutterView(rect, layoutManager, textContainer)
    }

    func drawMinimapGutterView(_ rect: CGRect,
                               _ layoutManager: NSLayoutManager,
                               _ lineMap: LineMap<LineInfo>,
                               _ textContainer: NSTextContainer) {

        // NOTE: There is a chance that the view may not even have been laid out fully yet.
        // However there is no reliable means of detecting this that I've found, so it just updates
        // all the time.
        updateGutter(for: rect)

        // Highlight the current line in the gutter
        if let location = textView.insertionPoint {
            theme.editor.lineHighlight.nsColor.setFill()
            layoutManager.enumerateFragmentRects(forLineContaining: location) { fragmentRect in
                let intersectionRect = rect.intersection(self.gutterRectFrom(textRect: fragmentRect))
                if !intersectionRect.isEmpty { NSBezierPath(rect: intersectionRect).fill() }
            }
        }

        for message in getMessageViews() {
            let glyphRange = layoutManager.glyphRange(
                forBoundingRect: message.value.lineFragementRect,
                in: textContainer
            ),
                index = layoutManager.characterIndexForGlyph(at: glyphRange.location)
            // TODO: should be filter by char range
            // if charRange.contains(index) {

            // NOTICE: Experimental (from Nanashi Li)
            message.value.colour.withAlphaComponent(0.1).setFill()
            layoutManager.enumerateFragmentRects(forLineContaining: index) { fragmentRect in
                let intersectionRect = rect.intersection(self.gutterRectFrom(textRect: fragmentRect))

                if !intersectionRect.isEmpty {
                    NSBezierPath(rect: intersectionRect).fill()
                }
            }
        }
    }

    func drawGutterView(_ rect: CGRect,
                        _ layoutManager: NSLayoutManager,
                        _ textContainer: NSTextContainer) {
        // FIXME: Eventually, we want this in the minimap
        //        but `messageView.value.lineFragementRect` is of course
        //        incorrect for the minimap, so we need a more general set up.

        // Highlight lines with messages
        for messageView in getMessageViews() {

            let glyphRange = layoutManager.glyphRange(
                forBoundingRect: messageView.value.lineFragementRect,
                in: textContainer
            ),
                index = layoutManager.characterIndexForGlyph(at: glyphRange.location)

            // TODO: should be filter by char range
            // if charRange.contains(index) {
            if glyphRange.contains(index) {
                messageView.value.colour.withAlphaComponent(0.1).setFill()
                layoutManager.enumerateFragmentRects(forLineContaining: index) { fragmentRect in
                    let intersectionRect = rect.intersection(self.gutterRectFrom(textRect: fragmentRect))

                    if !intersectionRect.isEmpty {
                        NSBezierPath(rect: intersectionRect).fill()
                    }
                }
            }
        }

        for itemIndex in 0..<lines.count {
            lines[itemIndex].draw(in: gutterRects[itemIndex],
                                          withAttributes: lineAttributes[itemIndex])
        }
    }

    func updateGutter(for rect: CGRect) {
        guard let layoutManager = optLayoutManager,
              let textContainer = optTextContainer,
              let lineMap = optLineMap,
              !isMinimapGutter // no need to update the gutter for a minimap
        else { return }

        let selectedLines = textView.selectedLines

        // All visible glyphs and all visible characters that are in the text area to the right of the gutter view
        let boundingRect = textRectFrom(gutterRect: rect)
        let glyphRange = layoutManager.glyphRange(forBoundingRectWithoutAdditionalLayout: boundingRect,
                                                  in: textContainer),
            charRange = layoutManager.characterRange(forGlyphRange: glyphRange, actualGlyphRange: nil)

        // Draw line numbers unless this is a gutter for a minimap
        let lineRange = lineMap.linesOf(range: charRange)

        // TODO: CodeEditor needs to be parameterised by message theme
        // let theme = Message.defaultTheme

        lines = []
        gutterRects = []
        lineAttributes = []

        for line in lineRange {

            // NB: We adjust the range, so that in case of a trailing empty line that last line break is not
            //     included in the second to last line (as otherwise, the bounding rect will contain both the
            //     second to last and last line together).
            let lineCharRange = lineMap.lines[line].range,
                lineGlyphRange = layoutManager.glyphRange(forCharacterRange: lineCharRange,
                                                          actualCharacterRange: nil),
                lineGlyphRect = layoutManager.boundingRect(forGlyphRange: lineGlyphRange, in: textContainer),
                gutterRect = gutterRectForLineNumbersFrom(textRect: lineGlyphRect)

            let attributes = selectedLines.contains(line) ? textAttributesSelected : textAttributesDefault

            lines.append("\(line)" as NSString)
            gutterRects.append(gutterRect)
            lineAttributes.append(attributes)
        }

        lastRefreshedFrame = rect
    }
}
