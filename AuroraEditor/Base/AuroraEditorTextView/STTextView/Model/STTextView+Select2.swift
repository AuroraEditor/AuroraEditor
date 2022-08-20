//
//  STTextView+Select2.swift
//  
//
//  Created by Wesley de Groot on 05/08/2022.
//

import Cocoa

extension STTextView {
    private func updateTextSelection(
        direction: NSTextSelectionNavigation.Direction,
        destination: NSTextSelectionNavigation.Destination,
        extending: Bool) {
            guard isSelectable else { return }

            textLayoutManager.textSelections = textLayoutManager.textSelections.compactMap { textSelection in
                textLayoutManager.textSelectionNavigation.destinationSelection(
                    for: textSelection,
                    direction: direction,
                    destination: destination,
                    extending: extending,
                    confined: false
                )
            }

            needScrollToSelection = true
            needsDisplay = true
        }

    internal func updateTextSelection(
        interactingAt point: CGPoint,
        inContainerAt location: NSTextLocation,
        anchors: [NSTextSelection] = [],
        extending: Bool,
        visual: Bool = false) {
            guard isSelectable else { return }

            var modifiers: NSTextSelectionNavigation.Modifier = []
            if extending {
                modifiers.insert(.extend)
            }
            if visual {
                modifiers.insert(.visual)
            }

            let selections = textLayoutManager.textSelectionNavigation.textSelections(
                interactingAt: point,
                inContainerAt: location,
                anchors: anchors,
                modifiers: modifiers,
                selecting: true,
                bounds: .zero)

            if !selections.isEmpty {
                textLayoutManager.textSelections = selections
            }

            updateSelectionHighlights()
            needsDisplay = true
        }

    override open func moveLeft(_ sender: Any?) {
        updateTextSelection(
            direction: .left,
            destination: .character,
            extending: false
        )
    }

    override open func moveLeftAndModifySelection(_ sender: Any?) {
        updateTextSelection(
            direction: .left,
            destination: .character,
            extending: true
        )
    }

    override open func moveRight(_ sender: Any?) {
        updateTextSelection(
            direction: .right,
            destination: .character,
            extending: false
        )
    }

    override open func moveRightAndModifySelection(_ sender: Any?) {
        updateTextSelection(
            direction: .right,
            destination: .character,
            extending: true
        )
    }

    override open func moveUp(_ sender: Any?) {
        updateTextSelection(
            direction: .up,
            destination: .character,
            extending: false
        )
    }

    override open func moveUpAndModifySelection(_ sender: Any?) {
        updateTextSelection(
            direction: .up,
            destination: .character,
            extending: true
        )
    }

    override open func moveDown(_ sender: Any?) {
        updateTextSelection(
            direction: .down,
            destination: .character,
            extending: false
        )
    }

    override open func moveDownAndModifySelection(_ sender: Any?) {
        updateTextSelection(
            direction: .down,
            destination: .character,
            extending: true
        )
    }

    override open func moveForward(_ sender: Any?) {
        updateTextSelection(
            direction: .forward,
            destination: .character,
            extending: false
        )
    }

    override open func moveForwardAndModifySelection(_ sender: Any?) {
        updateTextSelection(
            direction: .forward,
            destination: .character,
            extending: true
        )
    }

    override open func moveBackward(_ sender: Any?) {
        updateTextSelection(
            direction: .backward,
            destination: .character,
            extending: false
        )
    }

    override open func moveBackwardAndModifySelection(_ sender: Any?) {
        updateTextSelection(
            direction: .backward,
            destination: .character,
            extending: true
        )
    }

    override open func moveWordLeft(_ sender: Any?) {
        updateTextSelection(
            direction: .left,
            destination: .word,
            extending: false
        )
    }

    override open func moveWordLeftAndModifySelection(_ sender: Any?) {
        updateTextSelection(
            direction: .left,
            destination: .word,
            extending: true
        )
    }

    override open func moveWordRight(_ sender: Any?) {
        updateTextSelection(
            direction: .right,
            destination: .word,
            extending: false
        )
    }

    override open func moveWordRightAndModifySelection(_ sender: Any?) {
        updateTextSelection(
            direction: .right,
            destination: .word,
            extending: true
        )
    }

    override open func moveWordForward(_ sender: Any?) {
        updateTextSelection(
            direction: .forward,
            destination: .word,
            extending: false
        )
    }

    override open func moveWordForwardAndModifySelection(_ sender: Any?) {
        updateTextSelection(
            direction: .forward,
            destination: .word,
            extending: true
        )
    }

    override open func moveWordBackward(_ sender: Any?) {
        updateTextSelection(
            direction: .backward,
            destination: .word,
            extending: false
        )
    }

    override open func moveWordBackwardAndModifySelection(_ sender: Any?) {
        updateTextSelection(
            direction: .backward,
            destination: .word,
            extending: true
        )
    }

    override open func moveToBeginningOfLine(_ sender: Any?) {
        updateTextSelection(
            direction: .backward,
            destination: .line,
            extending: false
        )
    }

    override open func moveToBeginningOfLineAndModifySelection(_ sender: Any?) {
        updateTextSelection(
            direction: .backward,
            destination: .line,
            extending: true
        )
    }

    override open func moveToLeftEndOfLine(_ sender: Any?) {
        updateTextSelection(
            direction: .left,
            destination: .line,
            extending: false
        )
    }

    override open func moveToLeftEndOfLineAndModifySelection(_ sender: Any?) {
        updateTextSelection(
            direction: .left,
            destination: .line,
            extending: true
        )
    }

    override open func moveToEndOfLine(_ sender: Any?) {
        updateTextSelection(
            direction: .forward,
            destination: .line,
            extending: false
        )
    }

    override open func moveToEndOfLineAndModifySelection(_ sender: Any?) {
        updateTextSelection(
            direction: .forward,
            destination: .line,
            extending: true
        )
    }

    override open func moveToRightEndOfLine(_ sender: Any?) {
        updateTextSelection(
            direction: .right,
            destination: .line,
            extending: false
        )
    }

    override open func moveToRightEndOfLineAndModifySelection(_ sender: Any?) {
        updateTextSelection(
            direction: .right,
            destination: .line,
            extending: true
        )
    }

    override open func moveParagraphForwardAndModifySelection(_ sender: Any?) {
        updateTextSelection(
            direction: .forward,
            destination: .paragraph,
            extending: true
        )
    }

    override open func moveParagraphBackwardAndModifySelection(_ sender: Any?) {
        updateTextSelection(
            direction: .backward,
            destination: .paragraph,
            extending: true
        )
    }

    override open func moveToBeginningOfParagraph(_ sender: Any?) {
        updateTextSelection(
            direction: .backward,
            destination: .paragraph,
            extending: false
        )
    }

    override open func moveToBeginningOfParagraphAndModifySelection(_ sender: Any?) {
        updateTextSelection(
            direction: .backward,
            destination: .paragraph,
            extending: true
        )
    }

    override open func moveToEndOfParagraph(_ sender: Any?) {
        updateTextSelection(
            direction: .forward,
            destination: .paragraph,
            extending: false
        )
    }

    override open func moveToEndOfParagraphAndModifySelection(_ sender: Any?) {
        updateTextSelection(
            direction: .forward,
            destination: .paragraph,
            extending: true
        )
    }

    override open func moveToBeginningOfDocument(_ sender: Any?) {
        updateTextSelection(
            direction: .backward,
            destination: .document,
            extending: false
        )
    }

    override open func moveToBeginningOfDocumentAndModifySelection(_ sender: Any?) {
        updateTextSelection(
            direction: .backward,
            destination: .document,
            extending: true
        )
    }

    override open func moveToEndOfDocument(_ sender: Any?) {
        updateTextSelection(
            direction: .forward,
            destination: .document,
            extending: false
        )
    }

    override open func moveToEndOfDocumentAndModifySelection(_ sender: Any?) {
        updateTextSelection(
            direction: .forward,
            destination: .document,
            extending: true
        )
    }
}
