//
//  MinimapTypeSetter.swift
//  AuroraEditor
//
//  Created by Nanashi Li on 2022/09/24.
//  Copyright © 2022 Aurora Company. All rights reserved.
//

import AppKit

class MinimapTypeSetter: NSATSTypesetter {

    // Perform layout for the minimap. We don't layout the actual glyphs, but small rectangles representing the glyphs.
    //
    // This is a very simplified layout procedure that works for the specific setup of our code views. It completely
    // ignores some features of text views, such as areas to exclude, where `remainingRect` would be non-empty. It
    // currently also ignores all extra line and paragraph spacing and fails to call some methods that might adjust
    // layout decisions.
    override func layoutParagraph(
        at lineFragmentOrigin: UnsafeMutablePointer<NSPoint>
    ) -> Int {
        globalMainQueue.async {
            self.updateParagraphLayout(at: lineFragmentOrigin)
        }
        return NSMaxRange(paragraphSeparatorGlyphRange)
    }

    // TODO: Heavy optimisation since this is really slow, especially for large files
    func updateParagraphLayout( // swiftlint:disable:this function_body_length
        at lineFragmentOrigin: UnsafeMutablePointer<NSPoint>
    ) {
        let padding = currentTextContainer?.lineFragmentPadding ?? 0,
            width = currentTextContainer?.size.width ?? 100

        // Determine the size of the rectangles to layout. (They are always twice as high as wide.)
        var fontHeight: CGFloat
        if let charIndex = layoutManager?.characterIndexForGlyph(at: paragraphGlyphRange.location),
           let font = layoutManager?.textStorage?.attribute(.font, at: charIndex, effectiveRange: nil) as? NSFont {

            fontHeight = minimapFontSize(for: font.pointSize)

        } else { fontHeight = 2 }

        // We always leave one point of space between lines
        let lineHeight = fontHeight + 1,
            fontWidth = fontHeight / 2   // NB: This is always going to be an integral number

        beginParagraph()

        if paragraphGlyphRange.length > 0 {   // non-empty line

            var remainingGlyphRange = paragraphGlyphRange

            while remainingGlyphRange.length > 0 {

                var lineFragmentRect = NSRect.zero
                var remainingRect = NSRect.zero    // NB: we don't care about this as we don't supporte exclusions

                beginLine(withGlyphAt: remainingGlyphRange.location)

                getLineFragmentRect(&lineFragmentRect,
                                    usedRect: nil,
                                    remaining: &remainingRect,
                                    forStartingGlyphAt: remainingGlyphRange.location,
                                    proposedRect: NSRect(origin: lineFragmentOrigin.pointee,
                                                         size: CGSize(width: width, height: lineHeight)),
                                    lineSpacing: 0,
                                    paragraphSpacingBefore: 0,
                                    paragraphSpacingAfter: 0)

                let lineFragementRectEffectiveWidth = max(lineFragmentRect.size.width - 2 * padding, 0)

                // Determine how many glyphs we can fit into the `lineFragementRect`
                // must be at least one to make progress
                var numberOfGlyphs: Int,
                    lineGlyphRangeLength: Int
                var numberOfGlyphsThatFit = max(Int(floor(lineFragementRectEffectiveWidth / fontWidth)), 1)

                // Add any elastic glyphs that follow (they can be compacted)
                while numberOfGlyphsThatFit < remainingGlyphRange.length
                        && layoutManager?.propertyForGlyph(
                            at: remainingGlyphRange.location + numberOfGlyphsThatFit
                        ) == .elastic {
                    numberOfGlyphsThatFit += 1
                }

                if numberOfGlyphsThatFit < remainingGlyphRange.length { // we need a line break

                    // Try to find a break point at a word boundary, by looking back. If we don't find one,
                    // take the largest possible number of glyphs.
                    numberOfGlyphs = numberOfGlyphsThatFit
                glyphLoop: for glyphs in stride(from: numberOfGlyphsThatFit, to: 0, by: -1) {

                    let glyphIndex = remainingGlyphRange.location + glyphs - 1

                    var actualGlyphRange = NSRange(location: 0, length: 0)
                    let charIndex = characterRange(forGlyphRange: NSRange(location: glyphIndex, length: 1),
                                                   actualGlyphRange: &actualGlyphRange)
                    if actualGlyphRange.location < glyphIndex { continue }  // we are not yet at a character boundary

                    if layoutManager?.propertyForGlyph(at: glyphIndex) == .elastic
                        && shouldBreakLine(byWordBeforeCharacterAt: charIndex.location) {

                        // Found a valid break point
                        numberOfGlyphs = glyphs
                        break glyphLoop

                    }
                }

                    lineGlyphRangeLength = numberOfGlyphs

                } else {

                    numberOfGlyphs = remainingGlyphRange.length
                    lineGlyphRangeLength = numberOfGlyphs + paragraphSeparatorGlyphRange.length

                }

                let lineFragementUsedRect = NSRect(origin: CGPoint(x: lineFragmentRect.origin.x + padding,
                                                                   y: lineFragmentRect.origin.y),
                                                   size: CGSize(width: CGFloat(numberOfGlyphs), height: fontHeight))

                // The glyph range covered by this line fragement — this may include the paragraph separator glyphs
                let remainingLength = remainingGlyphRange.length - numberOfGlyphs,
                    lineGlyphRange = NSRange(location: remainingGlyphRange.location, length: lineGlyphRangeLength)

                // The rest of what remains of this paragraph
                remainingGlyphRange = NSRange(location: remainingGlyphRange.location + numberOfGlyphs,
                                              length: remainingLength)

                setLineFragmentRect(lineFragmentRect,
                                    forGlyphRange: lineGlyphRange,
                                    usedRect: lineFragementUsedRect,
                                    baselineOffset: 0)
                setLocation(NSPoint(x: padding, y: 0),
                            withAdvancements: nil, // Array(repeating: 1, count: numberOfGlyphs),
                            forStartOfGlyphRange: NSRange(location: lineGlyphRange.location, length: numberOfGlyphs))

                if remainingGlyphRange.length == 0 {

                    setLocation(NSPoint(x: lineFragementUsedRect.maxX, y: 0),
                                withAdvancements: nil,
                                forStartOfGlyphRange: paragraphSeparatorGlyphRange)
                    setNotShownAttribute(true, forGlyphRange: paragraphSeparatorGlyphRange)

                }

                endLine(withGlyphRange: lineGlyphRange)

                lineFragmentOrigin.pointee.y += lineHeight

            }

        } else {  // empty line

            beginLine(withGlyphAt: paragraphSeparatorGlyphRange.location)

            var lineFragmentRect = NSRect.zero,
                lineFragementUsedRect = NSRect.zero

            getLineFragmentRect(&lineFragmentRect,
                                usedRect: &lineFragementUsedRect,
                                forParagraphSeparatorGlyphRange: paragraphSeparatorGlyphRange,
                                atProposedOrigin: lineFragmentOrigin.pointee)

            setLineFragmentRect(lineFragmentRect,
                                forGlyphRange: paragraphSeparatorGlyphRange,
                                usedRect: lineFragementUsedRect,
                                baselineOffset: 0)
            setLocation(NSPoint.zero, withAdvancements: nil, forStartOfGlyphRange: paragraphSeparatorGlyphRange)
            setNotShownAttribute(true, forGlyphRange: paragraphSeparatorGlyphRange)

            endLine(withGlyphRange: paragraphSeparatorGlyphRange)

            lineFragmentOrigin.pointee.y += lineHeight

        }

        endParagraph()
    }

    // Adjust the height of the fragment rectangles for empty lines.
    override func getLineFragmentRect(_ lineFragmentRect: UnsafeMutablePointer<NSRect>,
                                      usedRect lineFragmentUsedRect: UnsafeMutablePointer<NSRect>,
                                      forParagraphSeparatorGlyphRange paragraphSeparatorGlyphRange: NSRange,
                                      atProposedOrigin lineOrigin: NSPoint) {
        // Determine the size of the rectangles to layout. (They are always twice as high as wide.)
        var fontHeight: CGFloat
        if let glyphIndex = (paragraphSeparatorGlyphRange.length > 0 ? paragraphSeparatorGlyphRange.location : nil) ??
            (paragraphSeparatorGlyphRange.location > 0 ? paragraphSeparatorGlyphRange.location - 1 : nil),
           let charIndex = layoutManager?.characterIndexForGlyph(at: glyphIndex),
           let font = layoutManager?.textStorage?.attribute(.font, at: charIndex, effectiveRange: nil) as? NSFont {

            fontHeight = minimapFontSize(for: font.pointSize)

        } else { fontHeight = 2 }

        // We always leave one point of space between lines
        let lineHeight = fontHeight + 1

        super.getLineFragmentRect(lineFragmentRect,
                                  usedRect: lineFragmentUsedRect,
                                  forParagraphSeparatorGlyphRange: paragraphSeparatorGlyphRange,
                                  atProposedOrigin: lineOrigin)
        lineFragmentRect.pointee.size.height = lineHeight
        lineFragmentUsedRect.pointee.size.height = fontHeight
    }
}
