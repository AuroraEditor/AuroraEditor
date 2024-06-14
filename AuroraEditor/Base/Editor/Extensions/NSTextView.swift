//
//  NSTextView.swift
//  Aurora Editor
//
//  Created by Nanashi Li on 2022/09/24.
//  Copyright © 2023 Aurora Company. All rights reserved.
//

import AppKit

extension NSTextView: TextView {
    typealias Color = NSColor
    typealias Font = NSFont

    /// The text view's text storage.
    var optLayoutManager: NSLayoutManager? { layoutManager }

    /// The text view's text storage.
    var optTextContainer: NSTextContainer? { textContainer }

    /// The text view's text storage.
    var optCodeStorage: CodeStorage? { textStorage as? CodeStorage }

    /// Background color of the text view.
    var textBackgroundColor: Color? { backgroundColor }

    /// Font of the text view.
    var textFont: Font? { font }

    /// Text color of the text view.
    var textContainerOrigin: CGPoint { return CGPoint(x: textContainerInset.width, y: textContainerInset.height) }

    /// Text color of the text view.
    var text: String! {
        get { string }
        set { string = newValue }
    }

    /// Insertion point of the text view.
    var insertionPoint: Int? {
        if let selection = selectedRanges.first as? NSRange, selection.length == 0 {
            return selection.location
        } else {
            return nil
        }
    }

    /// Selected ranges of the text view.
    var selectedLines: Set<Int> {
        guard let codeStorageDelegate = optCodeStorage?.delegate as? CodeStorageDelegate else { return Set() }

        let lineRanges: [Range<Int>] = selectedRanges.map { range in
            if let range = range as? NSRange {
                return codeStorageDelegate.lineMap.linesContaining(range: range)
            } else {
                return 0..<0
            }
        }
        return lineRanges.reduce(Set<Int>()) { $0.union($1) }
    }

    /// Visible rect of the text view.
    var documentVisibleRect: CGRect { enclosingScrollView?.documentVisibleRect ?? bounds }
}
