//
//  GutterView.swift
//  
//
//  Created by Manuel M T Chakravarty on 23/09/2020.
//

import os

private let logger = Logger(subsystem: "org.justtesting.CodeEditorView", category: "GutterView")

#if os(iOS)

// MARK: -
// MARK: UIKit version

import UIKit

private typealias FontDescriptor = UIFontDescriptor

private let fontDescriptorFeatureIdentifier = FontDescriptor.FeatureKey.featureIdentifier
private let fontDescriptorTypeIdentifier    = FontDescriptor.FeatureKey.typeIdentifier

private let lineNumberColour = UIColor(red: 0.5, green: 0.5, blue: 0.5, alpha: 0.5)

class GutterView: UIView {

  /// The text view that this gutter belongs to.
  ///
  let textView: UITextView

  /// The current code editor theme
  ///
  var theme: Theme

  /// Accessor for the associated text view's message views.
  ///
  let getMessageViews: () -> MessageViews

  /// Determines whether this gutter is for a main code view or for the minimap of a code view.
  ///
  let isMinimapGutter: Bool = false

  /// Dirty rectangle whose drawing has been delayed as the code layout wasn't finished yet.
  ///
  var pendingDrawRect: CGRect?

  /// Create and configure a gutter view for the given text view. This will also set the appropiate exclusion path for
  /// text container.
  ///
  init(frame: CGRect, textView: UITextView, theme: Theme, getMessageViews: @escaping () -> MessageViews) {
    self.textView        = textView
    self.theme           = theme
    self.getMessageViews = getMessageViews
    super.init(frame: frame)
    let gutterExclusionPath = UIBezierPath(rect: CGRect(origin: frame.origin,
                                                        size: CGSize(width: frame.width,
                                                                     height: CGFloat.greatestFiniteMagnitude)))
    optTextContainer?.exclusionPaths = [gutterExclusionPath]
    contentMode = .redraw
  }

  required init(coder: NSCoder) {
    fatalError("CodeEditorView.GutterView.init(coder:) not implemented")
  }
}

#elseif os(macOS)

// MARK: -
// MARK: AppKit version

import AppKit

private typealias FontDescriptor = NSFontDescriptor

private let fontDescriptorFeatureIdentifier = FontDescriptor.FeatureKey.typeIdentifier
private let fontDescriptorTypeIdentifier    = FontDescriptor.FeatureKey.selectorIdentifier

private let lineNumberColour = NSColor(red: 0.5, green: 0.5, blue: 0.5, alpha: 0.5)

class GutterView: NSView {

  /// The text view that this gutter belongs to.
  ///
  let textView: NSTextView

  /// The current code editor theme
  ///
  var theme: Theme

  /// Accessor for the associated text view's message views.
  ///
  let getMessageViews: () -> MessageViews

  /// Determines whether this gutter is for a main code view or for the minimap of a code view.
  ///
  let isMinimapGutter: Bool

  /// Dirty rectangle whose drawing has been delayed as the code layout wasn't finished yet.
  ///
  var pendingDrawRect: NSRect?

  /// Create and configure a gutter view for the given text view. This will also set the appropiate exclusion path for
  /// text container.
  ///
  init(frame: CGRect, textView: NSTextView, theme: Theme, getMessageViews: @escaping () -> MessageViews, isMinimapGutter: Bool) {
    self.textView        = textView
    self.theme           = theme
    self.getMessageViews = getMessageViews
    self.isMinimapGutter = isMinimapGutter
    super.init(frame: frame)
    // NB: If were decide to use layer backing, we need to set the `layerContentsRedrawPolicy` to redraw on resizing
  }

  required init(coder: NSCoder) {
    fatalError("CodeEditorView.GutterView.init(coder:) not implemented")
  }

  // Imitate the coordinate system of the associated text view.
  override var isFlipped: Bool { textView.isFlipped }
}

#endif

// MARK: -
// MARK: Shared code

extension GutterView {

  var optLayoutManager: NSLayoutManager? { textView.optLayoutManager }
  var optTextContainer: NSTextContainer? { textView.optTextContainer }
  var optLineMap: LineMap<LineInfo>? { textView.optLineMap }

  // MARK: -
  // MARK: Gutter notifications

  /// Notifies the gutter view that a range of characters will be redrawn by the layout manager or that there are
  /// selection status changes; thus, the corresponding gutter area might require redrawing, too.
  ///
  /// - Parameters:
  ///   - charRange: The invalidated range of characters. It will be trimmed to be within the valid character range of
  ///     the underlying text storage.
  ///
  /// We invalidate the area corresponding to entire paragraphs. This makes a difference in the presence of line
  /// breaks.
  ///
  func invalidateGutter(forCharRange charRange: NSRange) {

    guard let layoutManager = optLayoutManager,
          let textContainer = optTextContainer
    else { return }

    let string = textView.text as NSString

    let textRect: CGRect

    if charRange.location == string.length {   // special case: insertion point on trailing empty line

      textRect = layoutManager.extraLineFragmentRect

    } else {

      // We call `paragraphRange(for:_)` safely by boxing `charRange` to the allowed range.
      let extendedCharRange   = string.paragraphRange(for: NSIntersectionRange(charRange,
                                                                               NSRange(location: 0,
                                                                                       length: string.length))),
          glyphRange          = layoutManager.glyphRange(forCharacterRange: extendedCharRange,
                                                         actualCharacterRange: nil)
      textRect = layoutManager.boundingRect(forGlyphRange: glyphRange, in: textContainer)

    }
    setNeedsDisplay(gutterRectFrom(textRect: textRect))
  }

  /// Trigger drawing any pending gutter draw rectangle.
  ///
  func layoutFinished() {

    if let rect = pendingDrawRect {

      setNeedsDisplay(rect)
      pendingDrawRect = nil

    }
  }

  // MARK: -
  // MARK: Gutter drawing

  override func draw(_ rect: CGRect) {
    guard let layoutManager = optLayoutManager,
          let textContainer = optTextContainer,
          let lineMap       = optLineMap
    else { return }

    // This is not particularily nice, but there is no point in trying to draw the gutter, before the layout manager
    // has finished laying out the *entire* text. Given that all we got here is a rectangle, we can't even figure out
    // reliably whether enough text has been laid out to draw that part of the gutter that is being requested. Hence,
    // we defer drawing the gutter until all characters have been laid out.
    if layoutManager.firstUnlaidCharacterIndex() < NSMaxRange(lineMap.lines.last?.range ?? NSRange(location: 0,
                                                                                                   length: 0)) {

      pendingDrawRect = rect.union(pendingDrawRect ?? CGRect.null)
      return

    }

    theme.backgroundColour.setFill()
    OSBezierPath(rect: rect).fill()
    let desc = OSFont.systemFont(ofSize: theme.fontSize).fontDescriptor.addingAttributes(
      [ FontDescriptor.AttributeName.featureSettings:
          [
            [
              fontDescriptorFeatureIdentifier: kNumberSpacingType,
              fontDescriptorTypeIdentifier: kMonospacedNumbersSelector
            ],
            [
              fontDescriptorFeatureIdentifier: kStylisticAlternativesType,
              fontDescriptorTypeIdentifier: kStylisticAltOneOnSelector  // alt 6 and 9
            ],
            [
              fontDescriptorFeatureIdentifier: kStylisticAlternativesType,
              fontDescriptorTypeIdentifier: kStylisticAltTwoOnSelector  // alt 4
            ]
          ]
      ]
    )
    #if os(iOS)
    let font = OSFont(descriptor: desc, size: 0)
    #elseif os(macOS)
    let font = OSFont(descriptor: desc, size: 0) ?? OSFont.systemFont(ofSize: 0)
    #endif

    let selectedLines = textView.selectedLines

    // Currently only supported on macOS as `UITextView` is less configurable
    #if os(macOS)

    // Highlight the current line in the gutter
    if let location = textView.insertionPoint {

      theme.currentLineColour.setFill()
      layoutManager.enumerateFragmentRects(forLineContaining: location) { fragmentRect in
        let intersectionRect = rect.intersection(self.gutterRectFrom(textRect: fragmentRect))
        if !intersectionRect.isEmpty { NSBezierPath(rect: intersectionRect).fill() }
      }

    }

    // FIXME: Eventually, we want this in the minimap, too, but `messageView.value.lineFragementRect` is of course
    //        incorrect for the minimap, so we need a more general set up.
    if !isMinimapGutter {

      // Highlight lines with messages
      for messageView in getMessageViews() {

        let glyphRange = layoutManager.glyphRange(forBoundingRect: messageView.value.lineFragementRect, in: textContainer),
            index      = layoutManager.characterIndexForGlyph(at: glyphRange.location)
        // TODO: should be filter by char range
        //      if charRange.contains(index) {

        messageView.value.colour.withAlphaComponent(0.1).setFill()
        layoutManager.enumerateFragmentRects(forLineContaining: index) { fragmentRect in
          let intersectionRect = rect.intersection(self.gutterRectFrom(textRect: fragmentRect))
          if !intersectionRect.isEmpty { NSBezierPath(rect: intersectionRect).fill() }
        }

  //      }
      }
    }

    #endif

    // All visible glyphs and all visible characters that are in the text area to the right of the gutter view
    let glyphRange = layoutManager.glyphRange(forBoundingRectWithoutAdditionalLayout: textRectFrom(gutterRect: rect),
                                              in: textContainer),
        charRange  = layoutManager.characterRange(forGlyphRange: glyphRange, actualGlyphRange: nil)

    // Draw line numbers unless this is a gutter for a minimap
    if !isMinimapGutter {

      let lineRange = lineMap.linesOf(range: charRange)

      // Text attributes for the line numbers
      let lineNumberStyle = NSMutableParagraphStyle()
      lineNumberStyle.alignment = .right
      lineNumberStyle.tailIndent = -theme.fontSize / 11
      let textAttributesDefault  = [NSAttributedString.Key.font: font,
                                    .foregroundColor: lineNumberColour,
                                    .paragraphStyle: lineNumberStyle,
                                    .kern: NSNumber(value: Float(-theme.fontSize / 11))],
          textAttributesSelected = [NSAttributedString.Key.font: font,
                                    .foregroundColor: theme.textColour,
                                    .paragraphStyle: lineNumberStyle,
                                    .kern: NSNumber(value: Float(-theme.fontSize / 11))]

      // TODO: CodeEditor needs to be parameterised by message theme
      let theme = Message.defaultTheme

      for line in lineRange {

        // NB: We adjust the range, so that in case of a trailing empty line that last line break is not included in
        //     the second to last line (as otherwise, the bounding rect will contain both the second to last and last
        //     line together).
        let lineCharRange     = lineMap.lines[line].range,
            lineGlyphRange    = layoutManager.glyphRange(forCharacterRange: lineCharRange, actualCharacterRange: nil),
            lineGlyphRect     = layoutManager.boundingRect(forGlyphRange: lineGlyphRange, in: textContainer),
            gutterRect        = gutterRectForLineNumbersFrom(textRect: lineGlyphRect)

        var attributes = selectedLines.contains(line) ? textAttributesSelected : textAttributesDefault

        #if os(iOS)

        // Highlight line numbers as we don't have line background highlighting on iOS.
        if let messageBundle = lineMap.lines[line].info?.messages {
          let themeColour = theme(messagesByCategory(messageBundle.messages)[0].key).colour,
              colour      = selectedLines.contains(line) ? themeColour : themeColour.withAlphaComponent(0.5)
          attributes.updateValue(colour, forKey: .foregroundColor)
        }

        #endif

        ("\(line)" as NSString).draw(in: gutterRect, withAttributes: attributes)
      }
    }

  }
}

extension GutterView {

  /// Compute the full width rectangle in the gutter from a text container rectangle, such that they both have the same
  /// vertical extension.
  ///
  private func gutterRectFrom(textRect: CGRect) -> CGRect {
    return CGRect(origin: CGPoint(x: 0, y: textRect.origin.y + textView.textContainerOrigin.y),
                  size: CGSize(width: frame.size.width, height: textRect.size.height))
  }

  /// Compute the line number glyph rectangle in the gutter from a text container rectangle, such that they both have
  /// the same vertical extension.
  ///
  private func gutterRectForLineNumbersFrom(textRect: CGRect) -> CGRect {
    let gutterRect = gutterRectFrom(textRect: textRect)
    return CGRect(x: gutterRect.origin.x + gutterRect.size.width * 2/7,
                  y: gutterRect.origin.y,
                  width: gutterRect.size.width * 4/7,
                  height: gutterRect.size.height)
  }

  /// Compute the full width rectangle in the text container from a gutter rectangle, such that they both have the same
  /// vertical extension.
  ///
  private func textRectFrom(gutterRect: CGRect) -> CGRect {
    let containerWidth = optTextContainer?.size.width ?? 0
    return CGRect(origin: CGPoint(x: frame.size.width, y: gutterRect.origin.y - textView.textContainerOrigin.y),
                  size: CGSize(width:
                                containerWidth - frame.size.width,
                               height: gutterRect.size.height))
  }
}
