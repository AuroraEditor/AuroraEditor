//
//  TextView.swift
//  
//
//  Created by Manuel M T Chakravarty on 28/09/2020.
//
//  Text view protocol that extracts common functionality between 'UITextView' and 'NSTextView'.

import Foundation

// MARK: -
// MARK: The protocol

/// A protocol that bundles up the commonalities of 'UITextView' and 'NSTextView'.
///
protocol TextView {
  associatedtype Color
  associatedtype Font

  // This is necessary as these members are optional in AppKit and not optional in UIKit.
  var optLayoutManager: NSLayoutManager? { get }
  var optTextContainer: NSTextContainer? { get }
  var optCodeStorage: CodeStorage? { get }

  var textBackgroundColor: Color? { get }
  var textFont: Font? { get }
  var textContainerOrigin: CGPoint { get }

  /// The text displayed by the text view.
  ///
  var text: String! { get set }

  /// If the current selection is an insertion point (i.e., the selection length is 0), return its location.
  ///
  var insertionPoint: Int? { get }

  /// The current (single range) selection of the text view.
  ///
  var selectedRange: NSRange { get set }

  /// The set of lines that have characters that are included in the current selection. (This may be a multi-selection,
  /// and hence, a non-contiguous range.)
  ///
  var selectedLines: Set<Int> { get }

  /// The visible portion of the text view. (This only accounts for portions of the text view that are obscured through
  /// visibility in a scroll view.)
  ///
  var documentVisibleRect: CGRect { get }

  /// Temporarily highlight the visible part of the given range.
  ///
  func showFindIndicator(for range: NSRange)
}

extension TextView {

  /// The text view's line map.
  ///
  var optLineMap: LineMap<LineInfo>? {
    return (optCodeStorage?.delegate as? CodeStorageDelegate)?.lineMap
  }
}

#if os(iOS)

// MARK: -
// MARK: UIKit version

import UIKit

private let highlightingAttributes = [NSAttributedString.Key.foregroundColor: UIColor.black,
                                      NSAttributedString.Key.backgroundColor: UIColor.yellow]

extension UITextView: TextView {
  typealias Color = UIColor
  typealias Font  = UIFont

  var optLayoutManager: NSLayoutManager? { layoutManager }
  var optTextContainer: NSTextContainer? { textContainer }
  var optCodeStorage: CodeStorage? { textStorage as? CodeStorage }

  var textBackgroundColor: Color? { backgroundColor }
  var textFont: Font? { font }
  var textContainerOrigin: CGPoint { return CGPoint(x: textContainerInset.left, y: textContainerInset.top) }

  var insertionPoint: Int? { selectedRange.length == 0 ? selectedRange.location : nil }

  var selectedLines: Set<Int> {
    guard let codeStorageDelegate = optCodeStorage?.delegate as? CodeStorageDelegate else { return Set() }

    return Set(codeStorageDelegate.lineMap.linesContaining(range: selectedRange))
  }

  var documentVisibleRect: CGRect { return bounds }

  // This implementation currently comes with an infelicity. If there is already a indicator view visible, while this
  // method is called again, the old view should be removed right away. This is a bit awkward to implement, as we cannot
  // add a stored property in an extension, but it should happen eventually as it does look better.
  func showFindIndicator(for range: NSRange) {

    // Determine the visible portion of the range
    let visibleGlyphRange = layoutManager.glyphRange(forBoundingRectWithoutAdditionalLayout: documentVisibleRect,
                                                     in: textContainer),
        visibleCharRange  = layoutManager.characterRange(forGlyphRange: visibleGlyphRange, actualGlyphRange: nil),
        visibleRange      = NSIntersectionRange(visibleCharRange, range)

    // Set up a label view to animate as the indicator view
    let glyphRange = layoutManager.glyphRange(forCharacterRange: visibleRange, actualCharacterRange: nil),
        glyphRect  = layoutManager.boundingRect(forGlyphRange: glyphRange, in: textContainer),
        label      = UILabel(frame: glyphRect.offsetBy(dx: textContainerOrigin.x, dy: textContainerOrigin.y)),
        text       = NSMutableAttributedString(attributedString: textStorage.attributedSubstring(from: visibleRange))
    text.addAttributes(highlightingAttributes, range: NSRange(location: 0, length: text.length))
    label.attributedText      = text
    label.layer.cornerRadius  = 3
    label.layer.masksToBounds = true
    addSubview(label)

    // We animate the label in with a spring effect, and remove it with a delay.
    label.alpha     = 0
    label.transform = CGAffineTransform(scaleX: 0.2, y: 0.2)
    UIView.animate(withDuration: 0.2, delay: 0, usingSpringWithDamping: 0.1, initialSpringVelocity: 1) {
      label.alpha = 1
      label.transform = CGAffineTransform.identity
    } completion: { _ in
      UIView.animate(withDuration: 0.2, delay: 0.4) {
        label.alpha = 0
      } completion: { _ in
        label.removeFromSuperview()
      }
    }
  }
}

#elseif os(macOS)

// MARK: -
// MARK: AppKit version

import AppKit

extension NSTextView: TextView {
  typealias Color = NSColor
  typealias Font  = NSFont

  var optLayoutManager: NSLayoutManager? { layoutManager }
  var optTextContainer: NSTextContainer? { textContainer }
  var optCodeStorage: CodeStorage? { textStorage as? CodeStorage }

  var textBackgroundColor: Color? { backgroundColor }
  var textFont: Font? { font }
  var textContainerOrigin: CGPoint { return CGPoint(x: textContainerInset.width, y: textContainerInset.height) }

  var text: String! {
    get { string }
    set { string = newValue }
  }

  var insertionPoint: Int? {
    if let selection = selectedRanges.first as? NSRange, selection.length == 0 { return selection.location } else { return nil }
  }

  var selectedLines: Set<Int> {
    guard let codeStorageDelegate = optCodeStorage?.delegate as? CodeStorageDelegate else { return Set() }

    let lineRanges: [Range<Int>] = selectedRanges.map { range in
      if let range = range as? NSRange { return codeStorageDelegate.lineMap.linesContaining(range: range) } else { return 0..<0 }
    }
    return lineRanges.reduce(Set<Int>()) { $0.union($1) }
  }

  var documentVisibleRect: CGRect { enclosingScrollView?.documentVisibleRect ?? bounds }
}

#endif
