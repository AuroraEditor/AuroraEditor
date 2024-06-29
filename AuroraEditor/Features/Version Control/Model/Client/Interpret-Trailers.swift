//
//  Interpret-Trailers.swift
//  Aurora Editor
//
//  Created by Nanashi Li on 2022/08/13.
//  Copyright © 2023 Aurora Company. All rights reserved.
//
//  This source code is restricted for Aurora Editor usage only.
//

import Foundation

/// A representation of a Git commit message trailer.
protocol ITrailer {

    /// The token of the trailer.
    var token: String { get }

    /// The value of the trailer.
    var value: String { get }
}

/// A representation of a Git commit message trailer.
class Trailer: ITrailer {

    /// The token of the trailer.
    var token: String = ""

    /// The value of the trailer.
    var value: String = ""

    /// Initialize a new trailer with a token and value.
    /// 
    /// - Parameter token: The token of the trailer.
    /// - Parameter value: The value of the trailer.
    /// 
    /// - Returns: A new trailer instance.
    init(token: String, value: String) {
        self.token = token
        self.value = value
    }
}

/// Gets a value indicating whether the trailer token is
/// Co-Authored-By. Does not validate the token value.
/// 
/// - Parameter trailer: The trailer to check.
/// 
/// - Returns: True if the trailer token is Co-Authored-By.
func isCoAuthoredByTrailer(trailer: Trailer) -> Bool {
    return trailer.token.lowercased() == "co-authored-by"
}

/// Parse a string containing only unfolded trailers produced by
/// git-interpret-trailers --only-input --only-trailers --unfold or
/// a derivative such as git log --format="%(trailers:only,unfold)"
/// 
/// The trailers are expected to be in the format "token: value
/// token: value" etc. The trailers are expected to be separated
/// by newlines.
/// 
/// - Parameter trailers: The string containing the unfolded trailers.
/// - Parameter seperators: The characters that may be used to separate
/// tokens from values in commit message trailers.
/// 
/// - Returns: An array of ITrailer instances.
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

/// Parse a single unfolded trailer line.
/// 
/// - Parameter line: The line to parse.
/// - Parameter seperators: The characters that may be used to separate
/// tokens from values in commit message trailers.
/// 
/// - Returns: An ITrailer instance or nil if the line could not be parsed.
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
/// 
/// - Parameter directoryURL: The project url
///
/// - Returns: A string containing the characters that may be used to separate
func getTrailerSeparatorCharacters(directoryURL: URL) -> String {
    return ""
}

/// Extract commit message trailers from a commit message.
///
/// The trailers returned here are unfolded, i.e. they've had their
/// whitespace continuation removed and are all on one line.
/// 
/// - Parameter directoryURL: The project url.
/// - Parameter commitMessage: The commit message to extract trailers from.
/// 
/// - Returns: An array of ITrailer instances.
/// 
/// - Throws: ShellClientError
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
/// - Parameter directoryURL: The project url in which to run the interpret-
///                           trailers command. Although not intuitive this
///                           does matter as there are configuration options
///                           available for the format, position, etc of commit
///                           message trailers. See the manpage for
///                           git-interpret-trailers for more information.
/// - Parameter commitMessage: A commit message with or without existing commit
///                            message trailers into which to merge the trailers
///                            given in the trailers parameter
/// - Parameter trailers: Zero or more trailers to merge into the commit message
///
/// - Returns: A commit message string where the provided trailers (if)
///            any have been merged into the commit message using the
///            configuration settings for trailers in the provided
///            repository.
/// 
/// - Throws: ShellClientError
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
