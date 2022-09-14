//  Created by Marcin Krzyzanowski
//  https://github.com/krzyzanowskim/STTextView/blob/main/LICENSE.md

import Cocoa

extension STTextView {

    @objc open func copy(_ sender: Any?) {
        if textLayoutManager.textSelections.isEmpty,
        let documentString = textContentStorage.attributedString?.string,
        !documentString.isEmpty {
            updatePasteboard(with: documentString)
        } else if !textLayoutManager.textSelections.isEmpty {
            if let textSelectionsString = textLayoutManager.textSelectionsString(), !textSelectionsString.isEmpty {
                updatePasteboard(with: textSelectionsString)
            }
        }
    }

    @objc open func paste(_ sender: Any?) {
        guard let string = NSPasteboard.general.string(forType: .string),
              let firstTextSelectionRange = textLayoutManager.textSelections.first?.textRanges.first
        else {
            return
        }

        replaceCharacters(
            in: firstTextSelectionRange,
            with: string,
            useTypingAttributes: false,
            allowsTypingCoalescing: false)
    }

    @objc open func cut(_ sender: Any?) {
        copy(sender)
        delete(sender)
    }

    @objc open func delete(_ sender: Any?) {
        deleteToBeginningOfLine(sender)
    }

    private func updatePasteboard(with text: String) {
        let pasteboard = NSPasteboard.general
        pasteboard.clearContents()
        pasteboard.writeObjects([text as NSPasteboardWriting])
    }
}
