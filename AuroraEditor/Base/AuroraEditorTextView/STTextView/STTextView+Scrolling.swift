//  Created by Marcin Krzyzanowski
//  https://github.com/krzyzanowskim/STTextView/blob/main/LICENSE.md

import Cocoa

extension STTextView {

    override open func centerSelectionInVisibleArea(_ sender: Any?) {
        guard !textLayoutManager.textSelections.isEmpty else {
            return
        }

        scrollToSelection(textLayoutManager.textSelections[0])
        needsDisplay = true
    }

    override open func pageUp(_ sender: Any?) {
        assertionFailure()
    }

    override open func pageUpAndModifySelection(_ sender: Any?) {
        assertionFailure()
    }

    override open func pageDown(_ sender: Any?) {
        assertionFailure()
    }

    override open func pageDownAndModifySelection(_ sender: Any?) {
        assertionFailure()
    }

}
