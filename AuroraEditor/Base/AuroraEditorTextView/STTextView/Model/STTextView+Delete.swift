//  Created by Marcin Krzyzanowski
//  https://github.com/krzyzanowskim/STTextView/blob/main/LICENSE.md

import Cocoa

extension STTextView {

    override open func yank(_ sender: Any?) {
        cut(sender)
    }

    override open func deleteForward(_ sender: Any?) {
        delete(direction: .forward, destination: .character, allowsDecomposition: false)
    }

    override open func deleteBackward(_ sender: Any?) {
        delete(direction: .backward, destination: .character, allowsDecomposition: false)
    }

    override open func deleteBackwardByDecomposingPreviousCharacter(_ sender: Any?) {
        delete(direction: .backward, destination: .character, allowsDecomposition: true)
    }

    override open func deleteWordBackward(_ sender: Any?) {
        delete(direction: .backward, destination: .word, allowsDecomposition: false)
    }

    override open func deleteWordForward(_ sender: Any?) {
        delete(direction: .forward, destination: .word, allowsDecomposition: false)
    }

    override open func deleteToBeginningOfLine(_ sender: Any?) {
        delete(direction: .backward, destination: .line, allowsDecomposition: false)
    }

    override open func deleteToEndOfLine(_ sender: Any?) {
        delete(direction: .forward, destination: .line, allowsDecomposition: false)
    }

    override open func deleteToBeginningOfParagraph(_ sender: Any?) {
        delete(direction: .backward, destination: .paragraph, allowsDecomposition: false)
    }

    override open func deleteToEndOfParagraph(_ sender: Any?) {
        delete(direction: .forward, destination: .paragraph, allowsDecomposition: false)
    }

    private func delete(
        direction: NSTextSelectionNavigation.Direction,
        destination: NSTextSelectionNavigation.Destination,
        allowsDecomposition: Bool) {
        let textRanges = textLayoutManager.textSelections.flatMap { textSelection -> [NSTextRange] in
            if destination == .word {
                // FB9925766. deletionRanges only works correctly if textSelection is at the end of the word
                // Workaround
                return textLayoutManager.textSelectionNavigation.destinationSelection(
                    for: textSelection,
                    direction: direction,
                    destination: destination,
                    extending: true,
                    confined: false
                )?.textRanges ?? []
            } else {
                return textLayoutManager.textSelectionNavigation.deletionRanges(
                    for: textSelection,
                    direction: direction,
                    destination: destination,
                    allowsDecomposition: allowsDecomposition
                )
            }
        }

        if textRanges.isEmpty {
            return
        }

        var didChange = false
        textContentStorage.performEditingTransaction {
            for textRange in textRanges where shouldChangeText(in: textRange, replacementString: nil) {
                if didChange == false {
                    willChangeText()
                }

                didChange = true
                replaceCharacters(in: textRange, with: "", useTypingAttributes: false, allowsTypingCoalescing: true)
            }
        }

        if didChange {
            didChangeText()
        }
    }
}
