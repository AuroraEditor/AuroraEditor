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
