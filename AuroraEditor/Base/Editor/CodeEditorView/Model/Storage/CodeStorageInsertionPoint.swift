//
//  CodeStorageInsertionPoint.swift
//  Aurora Editor
//
//  Created by Nanashi Li on 2022/09/24.
//  Copyright © 2023 Aurora Company. All rights reserved.
//

import AppKit

extension CodeStorage {

    /// Insert the given string, such that it safe in an ongoing insertion cycle and does leave the cursor (insertion
    /// point) in place if the insertion is at the location of the insertion point.
    func cursorInsert(string: String, at index: Int) {

        Dispatch.DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + DispatchTimeInterval.milliseconds(10)) {
            // Collect the text views, where we insert at the insertion point
            var affectedTextViews: [NSTextView] = []
            for layoutManager in self.layoutManagers {
                for textContainer in layoutManager.textContainers {

                    if let textView = textContainer.textView,
                       textView.selectedRange() == NSRange(location: index, length: 0) {
                        affectedTextViews.append(textView)
                    }
                }
            }

            self.replaceCharacters(in: NSRange(location: index, length: 0), with: string)

            // Reset the insertion point to the original (pre-insertion) position
            // (as it will move after the inserted text on macOS otherwise)
            for textView in affectedTextViews { textView.setSelectedRange(NSRange(location: index, length: 0)) }
        }
    }

    /// Set the insertion point of all attached text views, where the selection intersects the given range, to the start
    /// of the range. This is safe in an editing cycle, as the selection setting is deferred until completion.
    ///
    /// - Parameter range: The deleted chracter range.
    func setInsertionPointAfterDeletion(of range: NSRange) {

        for layoutManager in self.layoutManagers {
            for textContainer in layoutManager.textContainers {

                if let codeContainer = textContainer as? CodeContainer,
                   let textView = codeContainer.textView,
                   NSIntersectionRange(textView.selectedRange, range).length != 0 {
                    Dispatch.DispatchQueue.main.async {
                        textView.selectedRange = NSRange(location: range.location, length: 0)
                    }
                }
            }
        }
    }
}
