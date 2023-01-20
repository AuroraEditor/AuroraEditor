//
//  MinimapLayoutManager.swift
//  Aurora Editor
//
//  Created by Nanashi Li on 2022/09/24.
//

import AppKit

/// Customised layout manager for the minimap.
class MinimapLayoutManager: NSLayoutManager {

    // In place of drawing the actual glyphs, we draw small rectangles in the glyph's foreground colour. We ignore the
    // actual glyph metrics and draw all glyphs as a fixed-sized rectangle whose height is determined by the "used
    // rectangle" and whose width is a fraction of the actual (monospaced) font of the glyph (rounded to full points).
    override func drawGlyphs(forGlyphRange glyphsToShow: NSRange, at origin: CGPoint) {
        guard let textStorage = self.textStorage else { return }

        // Compute the width of a single rectangle representing one character in the original text display.
        var width: CGFloat
        let charIndex = self.characterIndexForGlyph(at: glyphsToShow.location)
        if let font = textStorage.attribute(.font, at: charIndex, effectiveRange: nil) as? NSFont {

            width = minimapFontSize(for: font.pointSize) / 2

        } else { width = 1 }

        globalMainQueue.async {
            self.enumerateLineFragments(forGlyphRange: glyphsToShow) { (_, usedRect, _, glyphRange, _) in

                let origin = usedRect.origin
                for index in 0..<glyphRange.length {

                    // We don't draw hiden glyphs (`.null`), control chracters, and "elastic" glyphs, where the latter
                    // serve as a proxy for white space
                    let property = self.propertyForGlyph(at: glyphRange.location + index)
                    if property != .null && property != .controlCharacter && property != .elastic {

                        // TODO: could try to optimise by using the `effectiveRange` of \
                        // the attribute lookup to compute an entire glyph run to draw as one rectangle
                        let charIndex = self.characterIndexForGlyph(at: glyphRange.location + index)
                        if let colour = textStorage.attribute(.foregroundColor,
                                                              at: charIndex,
                                                              effectiveRange: nil) as? NSColor {
                            colour.withAlphaComponent(0.30).setFill()
                        }
                        NSBezierPath(rect: CGRect(x: origin.x + CGFloat(index),
                                                  y: origin.y,
                                                  width: width,
                                                  height: usedRect.size.height))
                        .fill()
                    }
                }
            }
        }
    }
}
