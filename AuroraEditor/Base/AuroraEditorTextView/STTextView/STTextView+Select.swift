//  Created by Marcin Krzyzanowski
//  https://github.com/krzyzanowskim/STTextView/blob/main/LICENSE.md

import Cocoa

extension STTextView {
    override open func selectAll(_ sender: Any?) {
        if isSelectable {
            textLayoutManager.textSelections = [
                NSTextSelection(range: textLayoutManager.documentRange, affinity: .downstream, granularity: .line)
            ]

            updateSelectionHighlights()
        }
    }

    override open func selectLine(_ sender: Any?) {
        guard let startSelection = textLayoutManager.textSelections.first else {
            return
        }

        textLayoutManager.textSelections = [
            textLayoutManager.textSelectionNavigation.textSelection(
                for: .line,
                enclosing: startSelection
            )
        ]

        needScrollToSelection = true
        needsDisplay = true
    }

    override open func selectWord(_ sender: Any?) {
        guard let startSelection = textLayoutManager.textSelections.first else {
            return
        }

        textLayoutManager.textSelections = [
            textLayoutManager.textSelectionNavigation.textSelection(
                for: .word,
                enclosing: startSelection
            )
        ]

        needScrollToSelection = true
        needsDisplay = true
    }

    override open func selectParagraph(_ sender: Any?) {
        guard let startSelection = textLayoutManager.textSelections.first else {
            return
        }

        textLayoutManager.textSelections = [
            textLayoutManager.textSelectionNavigation.textSelection(
                for: .paragraph,
                enclosing: startSelection
            )
        ]

        needScrollToSelection = true
        needsDisplay = true

    }
}
