//
//  CommitMessageFormatter.swift
//  Aurora Editor
//
//  Created by Wesley de Groot on 03/03/2024.
//  Copyright © 2024 Aurora Company. All rights reserved.
//

import Foundation
import Version_Control

struct CommitMessageFormatter {

    /**
     Formats a commit message for Git.

     - Parameters:
     - directoryURL: The URL of the directory where the commit is being made.
     - context: The `CommitContext` containing commit information.

     - Returns: A formatted commit message as a `String`.

     This function takes a `summary`, an optional `description`, and an optional array of `trailers`
     from a `CommitContext`. It concatenates the `summary` and `description`, ensuring they are
     separated by two newlines, and trims any trailing whitespace. If there are trailers, it attempts to merge
     them with the commit message.

     If merging trailers fails, it logs a debug message, but the commit message remains unchanged.

     - Note: Git always trims whitespace at the end of commit messages, so it's important to format
     the message accordingly.

     - Parameter directoryURL: The URL of the directory where the commit is being made.
     - Parameter context: The `CommitContext` containing commit information.

     - Returns: A formatted commit message as a `String`.
     - Throws: If merging trailers fails, it throws an error.

     - SeeAlso: `CommitContext`
     - SeeAlso: `mergeTrailers(directoryURL:commitMessage:trailers:)`
     */
    func formatCommitMessage(directoryURL: URL,
                             context: CommitContext) -> String {
        let summary = context.summary
        let description = context.description ?? ""
        let trailers = context.trailers

        // Git always trims whitespace at the end of commit messages,
        // so we concatenate the summary with the description, ensuring
        // that they're separated by two newlines. If we don't have a
        // description or if it consists solely of whitespace, that'll
        // all get trimmed away and replaced with a single newline (since
        // all commit messages need to end with a newline for Git
        // interpret-trailers to work).
        var message = "\(summary)\n\n\(description)\n"
            .replacingOccurrences(of: "\\s+$", with: "\n", options: .regularExpression)

        if let trailers = trailers, !trailers.isEmpty {
            do {
                message = try InterpretTrailers().mergeTrailers(directoryURL: directoryURL,
                                                                commitMessage: message,
                                                                trailers: trailers)
            } catch {
                Log.debug("Failed to merge trailers")
            }
        }

        return message
    }
}
