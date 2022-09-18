//
//  CodeView+Messages.swift
//  AuroraEditor
//
//  Created by TAY KAI QUAN on 18/9/22.
//  Copyright © 2022 Aurora Company. All rights reserved.
//

import AppKit

extension CodeView {

    /// Update the layout of the specified message view if its geometry got invalidated by
    /// `CodeTextContainer.lineFragmentRect(forProposedRect:at:writingDirection:remaining:)`.
    ///
    func layoutMessageView(
        identifiedBy id: UUID
    ) {
        guard let codeLayoutManager = layoutManager as? CodeLayoutManager,
              let codeStorage = textStorage as? CodeStorage,
              let codeContainer = optTextContainer,
              let messageBundle = messageViews[id]
        else { return }

        if messageBundle.geometry == nil {
            let glyphRange = codeLayoutManager.glyphRange(
                forBoundingRect: messageBundle.lineFragementRect,
                in: codeContainer
            ),
                charRange = codeLayoutManager.characterRange(
                    forGlyphRange: glyphRange,
                    actualGlyphRange: nil
                ),
                lineRange = (codeStorage.string as NSString).lineRange(for: charRange),
                lineGlyphs = codeLayoutManager.glyphRange(
                    forCharacterRange: lineRange,
                    actualCharacterRange: nil
                ),
                usedRect = codeLayoutManager.lineFragmentUsedRect(
                    forGlyphAt: glyphRange.location,
                    effectiveRange: nil
                ),
                lineRect = codeLayoutManager.boundingRect(forGlyphRange: lineGlyphs, in: codeContainer)

            // Compute the message view geometry from the text layout information
            let geometry = MessageView.Geometry(
                lineWidth: messageBundle.lineFragementRect.width - usedRect.width,
                lineHeight: messageBundle.lineFragementRect.height,
                popupWidth: (codeContainer.size.width - MessageView.popupRightSideOffset) * 0.75,
                popupOffset: lineRect.height + 2
            )
            messageViews[id]?.geometry = geometry

            // Configure the view with the new geometry
            messageBundle.view.geometry = geometry
            if messageBundle.view.superview == nil {

                // Add the messages view
                addSubview(messageBundle.view)
                let topOffset = textContainerOrigin.y + messageBundle.lineFragementRect.minY,
                    topAnchorConstraint = messageBundle.view.topAnchor.constraint(equalTo: self.topAnchor,
                                                                                  constant: topOffset)
                let leftOffset = textContainerOrigin.x + messageBundle.lineFragementRect.maxX,
                    rightAnchorConstraint = messageBundle.view.rightAnchor.constraint(equalTo: self.leftAnchor,
                                                                                      constant: leftOffset)
                messageViews[id]?.topAnchorConstraint = topAnchorConstraint
                messageViews[id]?.rightAnchorConstraint = rightAnchorConstraint
                NSLayoutConstraint.activate([topAnchorConstraint, rightAnchorConstraint])

            } else {

                // Update the messages view constraints
                messageViews[id]?.topAnchorConstraint?.constant = messageBundle.lineFragementRect.minY
                messageViews[id]?.rightAnchorConstraint?.constant = messageBundle.lineFragementRect.maxX

            }
        }
    }

    /// Adds a new message to the set of messages for this code view.
    ///
    func report(message: Located<Message>) {
        guard let messageBundle = codeStorageDelegate.add(message: message) else { return }

        updateMessageView(for: messageBundle, at: message.location.line)
    }

    /// Removes a given message. If it doesn't exist, do nothing. This function is quite expensive.
    ///
    func retract(message: Message) {
        guard let (messageBundle, line) = codeStorageDelegate.remove(message: message) else { return }

        updateMessageView(for: messageBundle, at: line)
    }

    /// Given a new or updated message bundle, update the corresponding message view appropriately.
    /// This includes covering the two special cases, where we create a new view or we remove a view for\
    ///  good (as its last message was deleted).
    private func updateMessageView(for messageBundle: LineInfo.MessageBundle, at line: Int) {
        guard let charRange = codeStorageDelegate.lineMap.lookup(line: line)?.range else { return }

        removeMessageViews(withIDs: [messageBundle.id])

        // If we removed the last message of this view, we don't need to create a new version
        if messageBundle.messages.isEmpty { return }

        // TODO: CodeEditor needs to be parameterised by message theme
        let theme = Message.defaultTheme

        let messageView = StatefulMessageView.HostingView(messages: messageBundle.messages,
                                                          theme: theme,
                                                          geometry: MessageView.Geometry(lineWidth: 100,
                                                                                         lineHeight: 15,
                                                                                         popupWidth: 300,
                                                                                         popupOffset: 16),
                                                          fontSize: font?.pointSize ?? OSFont.systemFontSize),
            principalCategory = messagesByCategory(messageBundle.messages)[0].key,
            colour = theme(principalCategory).colour

        messageViews[messageBundle.id] = MessageInfo(view: messageView,
                                                     lineFragementRect: CGRect.zero,
                                                     geometry: nil,
                                                     colour: colour)

        // We invalidate the layout of the line where the message belongs as their may be
        // less space for the text now and because the layout process for the text fills
        // the `lineFragmentRect` property of the above `MessageInfo`.
        optLayoutManager?.invalidateLayout(forCharacterRange: charRange, actualCharacterRange: nil)
        self.optLayoutManager?.invalidateDisplay(forCharacterRange: charRange)
        gutterView?.invalidateGutter(forCharRange: charRange)
    }

    /// Remove the messages associated with a specified range of lines.
    ///
    /// - Parameter onLines: The line range where messages are to be removed. If `nil`,\
    /// all messages on this code view are to be removed.
    func retractMessages(onLines lines: Range<Int>? = nil) {
        var messageIds: [LineInfo.MessageBundle.ID] = []

        // Remove all message bundles in the line map and collect their ids for subsequent view removal.
        for line in lines ?? 1..<codeStorageDelegate.lineMap.lines.count {

            if let messageBundle = codeStorageDelegate.messages(at: line) {

                messageIds.append(messageBundle.id)
                codeStorageDelegate.removeMessages(at: line)

            }

        }

        // Make sure to remove all views that are still around if necessary.
        if lines == nil { removeMessageViews() } else { removeMessageViews(withIDs: messageIds) }
    }

    /// Remove the message views with the given ids.
    ///
    /// - Parameter ids: The IDs of the message bundles that ought to be removed. If `nil`, remove all.
    ///
    /// IDs that do not have no associated message view cause no harm.
    ///
    func removeMessageViews(withIDs ids: [LineInfo.MessageBundle.ID]? = nil) {

        for id in ids ?? [LineInfo.MessageBundle.ID](messageViews.keys) {

            if let info = messageViews[id] { info.view.removeFromSuperview() }
            messageViews.removeValue(forKey: id)

        }
    }

    /// Ensure that all message views are in their collapsed state.
    ///
    func collapseMessageViews() {
        for messageView in messageViews {
            messageView.value.view.unfolded = false
        }
    }

}
