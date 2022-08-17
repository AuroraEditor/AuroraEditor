//
//  Interpret-Trailers.swift
//  AuroraEditor
//
//  Created by Nanashi Li on 2022/08/13.
//  Copyright © 2022 Aurora Company. All rights reserved.
//  This source code is restricted for Aurora Editor usage only.
//

import Foundation

/// A representation of a Git commit message trailer.
protocol ITrailer {
    var token: String { get }
    var value: String { get }
}

class Trailer: ITrailer {
    var token: String = ""
    var value: String = ""

    init(token: String, value: String) {
        self.token = token
        self.value = value
    }
}

/// Gets a value indicating whether the trailer token is
/// Co-Authored-By. Does not validate the token value.
func isCoAuthoredByTrailer(trailer: Trailer) -> Bool {
    return trailer.token.lowercased() == "co-authored-by"
}

/// Parse a string containing only unfolded trailers produced by
/// git-interpret-trailers --only-input --only-trailers --unfold or
/// a derivative such as git log --format="%(trailers:only,unfold)"
func parseRawUnfoldedTrailers(trailers: String, seperators: String) -> [ITrailer] {
    let lines = trailers.split(separator: "\n")
    var parsedTrailers: [ITrailer] = []

    for line in lines {
        let trailer = parseSingleUnfoldedTrailer(line: String(line),
                                                 seperators: seperators)

        // swiftlint:disable:next control_statement
        if (trailer != nil) {
            parsedTrailers.append(trailer!)
        }
    }

    return parsedTrailers
}

func parseSingleUnfoldedTrailer(line: String, seperators: String) -> ITrailer? {
    for seperator in seperators {
        let idx = line.firstIndex(of: seperator)?.utf16Offset(in: "")

        if idx! > 0 {
            return Trailer(token: line.substring(0).trimmingCharacters(in: .whitespaces),
                           value: line.substring(idx! + 1).trimmingCharacters(in: .whitespaces))
        }
    }
    return nil
}

/// Get a string containing the characters that may be used in this repository
/// separate tokens from values in commit message trailers. If no specific
/// trailer separator is configured the default separator (:) will be returned.
func getTrailerSeparatorCharacters(directoryURL: URL) -> String {
    return ""
}

/// Extract commit message trailers from a commit message.
///
/// The trailers returned here are unfolded, i.e. they've had their
/// whitespace continuation removed and are all on one line.
func parseTrailers(directoryURL: URL,
                   commitMessage: String) throws -> [ITrailer] {
    let result = try ShellClient.live().run(
        "cd \(directoryURL.relativePath.escapedWhiteSpaces());git interpret-trailers --parse")

    let trailers = result

    if trailers.isEmpty {
        return []
    }

    let seperators = getTrailerSeparatorCharacters(directoryURL: directoryURL)
    return parseRawUnfoldedTrailers(trailers: result, seperators: seperators)
}

/// Merge one or more commit message trailers into a commit message.
///
/// If no trailers are given this method will simply try to ensure that
/// any trailers that happen to be part of the raw message are formatted
/// in accordance with the configuration options set for trailers in
/// the given repository.
///
/// Note that configuration may be set so that duplicate trailers are
/// kept or discarded.
///
/// @param directoryURL - The project url in which to run the interpret-
/// trailers command. Although not intuitive this
/// does matter as there are configuration options
/// available for the format, position, etc of commit
/// message trailers. See the manpage for
/// git-interpret-trailers for more information.
///
/// @param commitMessage - A commit message with or without existing commit
/// message trailers into which to merge the trailers
/// given in the trailers parameter
///
/// @param trailers - Zero or more trailers to merge into the commit message
///
/// @returns - A commit message string where the provided trailers (if)
/// any have been merged into the commit message using the
/// configuration settings for trailers in the provided
/// repository.
func mergeTrailers(directoryURL: URL,
                   commitMessage: String,
                   trailers: [ITrailer],
                   unfold: Bool = false) throws -> String {
    var args = ["interpret-trailers"]

    args.append("--no-divider")

    if unfold {
        args.append("--unfold")
    }

    for trailer in trailers {
        args.append("--trailer \(trailer.token)=\(trailer.value)")
    }

    let result = try ShellClient.live().run(
        "cd \(directoryURL.relativePath.escapedWhiteSpaces());git \(args)")

    return result
}
