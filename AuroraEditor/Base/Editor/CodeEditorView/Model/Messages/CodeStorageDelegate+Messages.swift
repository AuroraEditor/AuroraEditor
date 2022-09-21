//
//  CodeStorageDelegate+Messages.swift
//  AuroraEditor
//
//  Created by TAY KAI QUAN on 18/9/22.
//  Copyright © 2022 Aurora Company. All rights reserved.
//

import AppKit

extension CodeStorageDelegate {

    /// Add the given message to the line info of the line where the message is located.
    ///
    /// - Parameter message: The message to add.
    /// - Returns: The message bundle to which the message was added, or `nil` if the line for which the message is
    ///     intended doesn't exist.
    ///
    /// NB: Ignores messages for lines that do not exist in the line map. A message may not be added to multiple lines.
    func add(message: Located<Message>) -> LineInfo.MessageBundle? {
        guard var info = lineMap.lookup(line: message.location.line)?.info else { return nil }

        if info.messages != nil {

            // Add a message to an existing message bundle for this line
            info.messages?.messages.append(message.entity)

        } else {

            // Create a new message bundle for this line with the new message
            info.messages = LineInfo.MessageBundle(messages: [message.entity])

        }
        lineMap.setInfoOf(line: message.location.line, to: info)
        return info.messages
    }

    /// Remove the given message from the line info in which it is located. This function is quite expensive.
    ///
    /// - Parameter message: The message to remove.
    /// - Returns: The updated message bundle from which the message was removed together with the line
    ///     where it occured, or `nil` if the message occurs in no line bundle.
    ///
    /// NB: Ignores messages that do not exist in the line map. It is considered an error if a message exists at
    ///     multiple lines. In this case, the occurences at the first such line will be used.
    func remove(message: Message) -> (LineInfo.MessageBundle, Int)? {

        for line in lineMap.lines.indices {

            if var info = lineMap.lines[line].info {
                if let idx = info.messages?.messages.firstIndex(of: message) {

                    info.messages?.messages.remove(at: idx)
                    lineMap.setInfoOf(line: line, to: info)
                    if let messages = info.messages { return (messages, line) } else { return nil }

                }
            }
        }
        return nil
    }

    /// Returns the message bundle associated with the given line if it exists.
    ///
    /// - Parameter line: The line for which we want to know the associated message bundle.
    /// - Returns: The message bundle associated with the given line or `nil`.
    ///
    /// NB: In case that the line does not exist, an empty array is returned.
    func messages(at line: Int) -> LineInfo.MessageBundle? { return lineMap.lookup(line: line)?.info?.messages }

    /// Remove all messages associated with a given line.
    ///
    /// - Parameter line: The line whose messages ought ot be removed.
    func removeMessages(at line: Int) {
        guard var info = lineMap.lookup(line: line)?.info else { return }

        info.messages = nil
        lineMap.setInfoOf(line: line, to: info)
    }
}
