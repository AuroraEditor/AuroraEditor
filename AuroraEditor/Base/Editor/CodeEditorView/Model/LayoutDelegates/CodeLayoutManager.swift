//
//  CodeLayoutManager.swift
//  AuroraEditor
//
//  Created by TAY KAI QUAN on 18/9/22.
//  Copyright © 2022 Aurora Company. All rights reserved.
//

import AppKit

/// Customised layout manager for code layout.
class CodeLayoutManager: NSLayoutManager {

    weak var gutterView: GutterView?

    override func processEditing(for textStorage: NSTextStorage,
                                 edited editMask: TextStorageEditActions,
                                 range newCharRange: NSRange,
                                 changeInLength delta: Int,
                                 invalidatedRange invalidatedCharRange: NSRange) {
        super.processEditing(for: textStorage,
                             edited: editMask,
                             range: newCharRange,
                             changeInLength: delta,
                             invalidatedRange: invalidatedCharRange)

        // NB: Gutter drawing must be asynchronous, as the glyph generation that may be triggered in that process,
        //     is not permitted until the enclosing editing block has completed; otherwise, we run into an internal
        //     error in the layout manager.
        if let gutterView = gutterView {
            Dispatch.DispatchQueue.main.async { gutterView.invalidateGutter(forCharRange: invalidatedCharRange) }
        }

        // Remove all messages in the edited range.
        if let codeStorageDelegate = textStorage.delegate as? CodeStorageDelegate,
           let codeView = gutterView?.textView as? CodeView {

            codeView.removeMessageViews(withIDs: codeStorageDelegate.lastEvictedMessageIDs)

        }
    }

    /// Custom background drawing is done first, then default background drawing is done,
    /// potentially overriding the custom background drawing. Inspiration from
    /// https://instagram-engineering.com/building-type-mode-for-stories-on-ios-and-android-8804e927feba
    override public func drawBackground(forGlyphRange glyphsToShow: NSRange, at origin: NSPoint) {
        defer {
            // Call super last to apply normal highlighting with higher priority.
            super.drawBackground(forGlyphRange: glyphsToShow, at: origin)
        }

        guard let textStorage = textStorage else {
            return
        }

        // We are guaranteed that the glyph range will all be in one text container
        guard let textContainer = textContainer(forGlyphAt: glyphsToShow.location, effectiveRange: nil) else {
            return
        }

        textStorage.enumerateAttribute(BackgroundColorThemeAttribute.RoundedBackground.Key,
                                       in: glyphsToShow, using: { (value, range, _) in
            // Check we've got a color
            guard let roundedBackground = value as? BackgroundColorThemeAttribute.RoundedBackground else {
                return
            }

            if roundedBackground.coloringStyle == .textOnly {
                var rectCount = -1
                guard let rectArray = self.rectArray(forCharacterRange: range,
                                                     withinSelectedCharacterRange: range,
                                                     in: textContainer, rectCount: &rectCount) else {
                    fatalError("""
Failed to received rect array for characterRange: \(range), \
within selected character range: \(range), in text container: \(textContainer)
""")
                }

                guard rectCount != -1 else {
                    fatalError("Failed to receive rect array count.")
                }

                let lineHeight = lineFragmentRect(forGlyphAt: range.location, effectiveRange: nil).height
                let cornerRadius = lineHeight * roundedBackground.roundingStyle.rawValue / 2

                // Adjust for text container insets
                for rectIndex in 0..<rectCount {
                    rectArray[rectIndex] = rectArray[rectIndex].offsetBy(dx: origin.x, dy: origin.y)
                    // TODO: Move into RoundedBackground class.
                    let leftInset: CGFloat = -1
                    let rightInset: CGFloat = -1
                    rectArray[rectIndex] = rectArray[rectIndex].insetBy(dx: leftInset + rightInset, dy: 0)
                    rectArray[rectIndex] = rectArray[rectIndex].offsetBy(dx: (leftInset - rightInset)/2, dy: 0)
                }

                self.fillRoundedBackgroundRectArray(rectArray,
                                                    count: rectCount,
                                                    color: roundedBackground.color,
                                                    cornerRadius: cornerRadius)
            } else if roundedBackground.coloringStyle == .line {
                var rect = getBlockRect(forRange: range)
                let cornerRadius = lineFragmentRect(forGlyphAt: range.location, effectiveRange: nil).height *
                roundedBackground.roundingStyle.rawValue / 2

                // Adjust for text container insets
                rect = rect.offsetBy(dx: origin.x, dy: origin.y)

                self.fillRoundedBackgroundRect(rect, color: roundedBackground.color, cornerRadius: cornerRadius)
            }
        })
    }

    func getBlockRect(forRange range: NSRange) -> NSRect {
        var targetRange = range

        var blockRect: NSRect?

        // Holder for the effective range
        var effectiveRange = NSRange(location: NSNotFound, length: 0)
        while true {
            let rect = lineFragmentRect(forGlyphAt: targetRange.location, effectiveRange: &effectiveRange)

            if effectiveRange.location == NSNotFound {
                fatalError("Failed to retrieve range of textContainer when applying rounded background.")
            }

            if blockRect == nil {
                blockRect = rect
            } else {
                blockRect = blockRect!.union(rect)
            }

            // Not all of the target range is in this line fragment
            if targetRange.upperBound > effectiveRange.upperBound {
                // Update target range and reset effective range
                targetRange = NSRange(effectiveRange.upperBound..<targetRange.upperBound)
                effectiveRange = NSRange(location: NSNotFound, length: 0)
            }
            // All of the target range is in this text container
            else {
                break
            }
        }
        return blockRect!
    }

    // Adapted from: https://stackoverflow.com/a/44303971
    func fillRoundedBackgroundRectArray(_ rectArray: UnsafePointer<NSRect>,
                                        count rectCount: Int,
                                        color: NSColor,
                                        cornerRadius: CGFloat) {

        let path = getRoundedBackgroundPath(rectArray, count: rectCount, cornerRadius: cornerRadius)

        color.set()

        drawBackground(path: path, cornerRadius: cornerRadius)
    }

    private func drawBackground(path: CGPath, cornerRadius: CGFloat) {
        let cgContext = NSGraphicsContext.current?.cgContext
        cgContext?.setLineWidth(cornerRadius * 2.0)
        cgContext?.setLineJoin(.round)

        cgContext?.setAllowsAntialiasing(true)
        cgContext?.setShouldAntialias(true)

        cgContext?.addPath(path)
        cgContext?.drawPath(using: .fillStroke)
    }

    func getRoundedBackgroundPath(_ rectArray: UnsafePointer<NSRect>,
                                  count rectCount: Int,
                                  cornerRadius: CGFloat) -> CGPath {

        let path = CGMutablePath()

        if rectCount == 1 || (rectCount == 2 && (rectArray[1].maxX < rectArray[0].maxX)) {
            path.addRect(rectArray[0].insetBy(dx: cornerRadius, dy: cornerRadius))

            if rectCount == 2 {
                path.addRect(rectArray[1].insetBy(dx: cornerRadius, dy: cornerRadius))
            }

        } else {
            let lastRect = rectCount - 1

            path.move(to: CGPoint(x: rectArray[0].minX + cornerRadius, y: rectArray[0].maxY + cornerRadius))

            path.addLine(to: CGPoint(x: rectArray[0].minX + cornerRadius, y: rectArray[0].minY + cornerRadius))
            path.addLine(to: CGPoint(x: rectArray[0].maxX - cornerRadius, y: rectArray[0].minY + cornerRadius))

            path.addLine(to: CGPoint(x: rectArray[0].maxX - cornerRadius, y: rectArray[lastRect].minY - cornerRadius))
            path.addLine(to: CGPoint(x: rectArray[lastRect].maxX - cornerRadius,
                                     y: rectArray[lastRect].minY - cornerRadius))

            path.addLine(to: CGPoint(x: rectArray[lastRect].maxX - cornerRadius,
                                     y: rectArray[lastRect].maxY - cornerRadius))
            path.addLine(to: CGPoint(x: rectArray[lastRect].minX + cornerRadius,
                                     y: rectArray[lastRect].maxY - cornerRadius))

            path.addLine(to: CGPoint(x: rectArray[lastRect].minX + cornerRadius,
                                     y: rectArray[0].maxY + cornerRadius))

            path.closeSubpath()
        }

        return path
    }

    func fillRoundedBackgroundRect(_ rect: NSRect, color: NSColor, cornerRadius: CGFloat) {
        let path = CGMutablePath()

        path.addRect(rect.insetBy(dx: cornerRadius, dy: cornerRadius))

        color.set()

        drawBackground(path: path, cornerRadius: cornerRadius)
    }
}

extension NSLayoutManager {

    /// Enumerate the fragment rectangles covering the characters located on the line with the given character index.
    ///
    /// - Parameters:
    ///   - charIndex: The character index determining the line whose rectangles we want to enumerate.
    ///   - block: Block that gets invoked once for every fragement rectangles on that line.
    func enumerateFragmentRects(forLineContaining charIndex: Int, using block: @escaping (CGRect) -> Void) {
        guard let text = textStorage?.string as NSString? else { return }

        let currentLineCharRange = text.lineRange(for: NSRange(location: charIndex, length: 0))

        if currentLineCharRange.length > 0 {  // all, but the last line (if it is an empty line)

            let currentLineGlyphRange = glyphRange(forCharacterRange: currentLineCharRange, actualCharacterRange: nil)
            enumerateLineFragments(forGlyphRange: currentLineGlyphRange) { (rect, _, _, _, _) in block(rect) }

        } else {                              // the last line if it is an empty line

            block(extraLineFragmentRect)

        }
    }
}
