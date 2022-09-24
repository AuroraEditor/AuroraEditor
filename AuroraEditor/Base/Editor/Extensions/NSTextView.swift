//
//  NSTextView.swift
//  AuroraEditor
//
//  Created by Nanashi Li on 2022/09/24.
//  Copyright © 2022 Aurora Company. All rights reserved.
//

import AppKit

extension NSTextView: TextView {
    typealias Color = NSColor
    typealias Font = NSFont

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
        if let selection = selectedRanges.first as? NSRange, selection.length == 0 {
            return selection.location
        } else {
            return nil
        }
    }

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

    var documentVisibleRect: CGRect { enclosingScrollView?.documentVisibleRect ?? bounds }
}
