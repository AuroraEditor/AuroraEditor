//
//  TextView.swift
//  Aurora Editor
//
//  Created by Manuel M T Chakravarty on 28/09/2020.
//
//  Text view protocol that extracts common functionality between 'UITextView' and 'NSTextView'.

import AppKit

// MARK: - The protocol

/// A protocol that bundles up the commonalities of 'UITextView' and 'NSTextView'.
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
    var text: String! { get set }

    /// If the current selection is an insertion point (i.e., the selection length is 0), return its location.
    var insertionPoint: Int? { get }

    /// The current (single range) selection of the text view.
    var selectedRange: NSRange { get set }

    /// The set of lines that have characters that are included in the current selection.
    /// (This may be a multi-selection, and hence, a non-contiguous range.)
    var selectedLines: Set<Int> { get }

    /// The visible portion of the text view. (This only accounts for portions of the text
    /// view that are obscured through visibility in a scroll view.)
    var documentVisibleRect: CGRect { get }

    /// Temporarily highlight the visible part of the given range.
    func showFindIndicator(for range: NSRange)
}

extension TextView {

    /// The text view's line map.
    var optLineMap: LineMap<LineInfo>? {
        return (optCodeStorage?.delegate as? CodeStorageDelegate)?.lineMap
    }
}
