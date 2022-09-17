//
//  AuroraEditorTextView+Minimap.swift
//  AuroraEditor
//
//  Created by TAY KAI QUAN on 17/9/22.
//  Copyright © 2022 Aurora Company. All rights reserved.
//

import SwiftUI

extension AuroraEditorTextView {

    /// Adds a minimap view to a controller, creating one if it doesn't exist
    /// - Parameters:
    ///   - controller: The controller to add the minimap view to
    ///   - overrideMinimap: The minimap to add. If nil, it tries to look for a saved one.
    ///   If there are no saved minimaps, it creates one.
    func addMinimapView(to controller: NSViewControllerType,
                        minimapView overrideMinimap: NSHostingView<MinimapView>? = nil) {
        if let minimapView = overrideMinimap ?? self.minimapView {
            if let scrollContent = controller.textView.scrollView {
                minimapView.frame = NSRect(x: scrollContent.frame.width-150,
                                            y: 0,
                                            width: 150,
                                            height: scrollContent.frame.height)
                scrollContent.addSubview(minimapView)
            }
        } else {
            let minimapView = NSHostingView(rootView: MinimapView(attributedTextItems: $attributedTextItems,
                                                                  scrollAmount: $scrollAmount))
            DispatchQueue.main.async {
                self.minimapView = minimapView
            }
            addMinimapView(to: controller, minimapView: minimapView)
        }
    }

    /// Takes an attributed string and turns it into an array of ``AttributedStringItem``s
    /// - Parameter attributedText: The attributed string to parse
    func updateTextItems(attributedText: NSAttributedString) {
        let length = attributedText.length

        var newAttributedTextItems: [AttributedStringItem] = []

        var position = 0
        while position < length {
            // get the attributes
            var range = NSRange()
            let attributes = attributedText.attributes(at: position, effectiveRange: &range)
            let atString = attributedText.string

            // get the line number by counting the number of newlines until the string starts
            let rangeSoFar = atString.startIndex..<atString.index(atString.startIndex, offsetBy: position)
            let stringSoFar = String(attributedText.string[rangeSoFar])
            let separatedComponents = stringSoFar.components(separatedBy: "\n")
            var newLines = separatedComponents.count - 1
            var charFromStart = separatedComponents.last?.count ?? 0

            // get the contents of the range
            let rangeContents = atString[range] ?? ""

            // split by \n characters and spaces
            let lines = String(rangeContents).components(separatedBy: "\n")

            for line in lines {
                let words = line.components(separatedBy: " ")
                for word in words {
                    if !word.isEmpty {
                        newAttributedTextItems.append(AttributedStringItem(text: word,
                                                                           lineNumber: newLines,
                                                                           charactersFromStart: charFromStart,
                                                                           range: range,
                                                                           attributes: attributes))
                    }

                    // modify the charactersFromStart for each word
                    charFromStart += word.count + 1
                }

                // modify the line number and charactersFromStart for each line
                charFromStart = 0
                newLines += 1
            }

            position = range.upperBound
        }

        attributedTextItems = newAttributedTextItems
    }
}
