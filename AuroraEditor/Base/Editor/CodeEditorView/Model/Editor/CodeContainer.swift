//
//  CodeContainer.swift
//  Aurora Editor
//
//  Created by TAY KAI QUAN on 18/9/22.
//

import AppKit

class CodeContainer: NSTextContainer {

    override func lineFragmentRect(forProposedRect proposedRect: CGRect,
                                   at characterIndex: Int,
                                   writingDirection baseWritingDirection: NSWritingDirection,
                                   remaining remainingRect: UnsafeMutablePointer<CGRect>?)
    -> CGRect {
        let calculatedRect = super.lineFragmentRect(forProposedRect: proposedRect,
                                                    at: characterIndex,
                                                    writingDirection: baseWritingDirection,
                                                    remaining: remainingRect)

        guard let codeView = textView as? CodeView,
              let codeStorage = layoutManager?.textStorage as? CodeStorage,
              let delegate = codeStorage.delegate as? CodeStorageDelegate,
              let line = delegate.lineMap.lineOf(index: characterIndex),
              let oneLine = delegate.lineMap.lookup(line: line),
              characterIndex == oneLine.range.location    // we are only interested in the first line fragment of a line
        else { return calculatedRect }

        // On lines that contain messages, we reduce the width of the available line fragement rect such that there is
        // always space for a minimal truncated message (provided the text container is wide enough to accomodate that).
        if let messageBundleId = delegate.messages(at: line)?.id,
           calculatedRect.width > 2 * MessageView.minimumInlineWidth {

            codeView.messageViews[messageBundleId]?.lineFragementRect = calculatedRect
            codeView.messageViews[messageBundleId]?.geometry = nil // invalidate the geometry

            // To fully determine the layout of the message view,
            // typesetting needs to complete for this line; hence, we defer
            // configuring the view.
            DispatchQueue.main.async { codeView.layoutMessageView(identifiedBy: messageBundleId) }

            return CGRect(origin: calculatedRect.origin,
                          size: CGSize(width: calculatedRect.width - MessageView.minimumInlineWidth,
                                       height: calculatedRect.height))

        } else { return calculatedRect }
    }
}
