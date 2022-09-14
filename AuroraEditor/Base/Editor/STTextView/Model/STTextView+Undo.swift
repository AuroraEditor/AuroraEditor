//  Created by Marcin Krzyzanowski
//  https://github.com/krzyzanowskim/STTextView/blob/main/LICENSE.md

import Foundation
import Cocoa

// NSResponder.undoManager doesn work out of the box (as 03.2022, macOS 12.3)
// see https://gist.github.com/krzyzanowskim/1a13f27e6b469ca2ffcf9b53588b837a

extension STTextView {

    override open var undoManager: UndoManager? {
        allowsUndo ? internalUndoManager : nil
    }

    @objc func undo(_ sender: AnyObject?) {
        undoManager?.undo()
    }

    @objc func redo(_ sender: AnyObject?) {
        undoManager?.redo()
    }

}
