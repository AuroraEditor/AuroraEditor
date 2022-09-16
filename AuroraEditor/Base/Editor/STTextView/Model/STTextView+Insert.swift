//  Created by Marcin Krzyzanowski
//  https://github.com/krzyzanowskim/STTextView/blob/main/LICENSE.md

import Cocoa

extension STTextView {

    override open func insertLineBreak(_ sender: Any?) {
        insertNewline(sender)
    }

    override open func insertTab(_ sender: Any?) {
        insertText("\t")
    }

    override open func insertNewline(_ sender: Any?) {
        insertText("\n")
    }

    override open func insertText(_ insertString: Any) {
        insertText(insertString, replacementRange: NSRange.notFound)
    }

}
