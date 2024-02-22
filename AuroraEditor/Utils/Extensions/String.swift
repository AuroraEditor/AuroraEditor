//
//  String.swift
//  Aurora Editor
//
//  Created by Nanashi Li on 2022/08/04.
//  Copyright © 2023 Aurora Company. All rights reserved.
//

import Foundation
import AppKit
import CryptoKit

extension String {

    var lastPathComponent: String {
        return NSString(string: self).lastPathComponent
    }

    var stringByDeletingPathExtension: String {
        return NSString(string: self).deletingPathExtension
    }

    /**
     Returns a string colored with the specified color.
     - parameter color: The string representation of the color.
     - returns: A string colored with the specified color.
     */
    func withColor(_ color: String?) -> String {
        return ""
    }

    func capitalizingFirstLetter() -> String {
        return prefix(1).uppercased() + self.lowercased().dropFirst()
    }

    mutating func capitalizeFirstLetter() {
        self = self.capitalizingFirstLetter()
    }

    // MARK: Offsets

    /// Safely returns an offset index in a string.
    /// Use ``safeOffset(_:offsetBy:)`` to default to limiting to the start or end indexes.
    /// - Parameters:
    ///   - idx: The index to start at.
    ///   - offsetBy: The number (of characters) to offset from the first index.
    ///   - limitedBy: An index to limit the offset by.
    /// - Returns: A `String.Index`
    func safeOffset(_ idx: String.Index, offsetBy offset: Int, limitedBy: String.Index) -> String.Index {
        // This is the odd case this method solves. Swift's
        // ``String.index(_:offsetBy:limitedBy:)``
        // will crash if the given index is equal to the offset, and
        // we try to go outside of the string's limits anyways.
        if idx == limitedBy {
            return limitedBy
        } else if offset < 0 {
            // If the offset is going backwards, but the limit index
            // is ahead in the string we return the original index.
            if limitedBy > idx {
                return idx
            }

            // Return the index offset by the given offset.
            // If this index is nil we return the limit index.
            return index(idx,
                         offsetBy: offset,
                         limitedBy: limitedBy) ?? limitedBy
        } else if offset > 0 {
            // If the offset is going forwards, but the limit index
            // is behind in the string we return the original index.
            if limitedBy < idx {
                return idx
            }

            // Return the index offset by the given offset.
            // If this index is nil we return the limit index.
            return index(idx,
                         offsetBy: offset,
                         limitedBy: limitedBy) ?? limitedBy
        } else {
            // The offset is 0, so we return the limit index.
            return limitedBy
        }
    }

    /// Safely returns an offset index in a string.
    /// This method will default to limiting to the start or end of the string.
    /// See ``safeOffset(_:offsetBy:limitedBy:)`` for custom limit indexes.
    /// - Parameters:
    ///   - idx: The index to start at.
    ///   - offsetBy: The number (of characters) to offset from the first index.
    /// - Returns: A `String.Index`
    func safeOffset(_ idx: String.Index, offsetBy offset: Int) -> String.Index {
        if offset < 0 {
            return safeOffset(idx, offsetBy: offset, limitedBy: self.startIndex)
        } else if offset > 0 {
            return safeOffset(idx, offsetBy: offset, limitedBy: self.endIndex)
        } else {
            // If the offset is 0 we return the original index.
            return idx
        }
    }

    func escapedWhiteSpaces() -> String {
        self.replacingOccurrences(of: " ", with: "\\ ")
    }

    /// Escape single quotes
    func escapedQuotes() -> String {
        return self.replacingOccurrences(of: "'", with: "\'")
    }

    func index(from: Int) -> Index {
        return self.index(self.startIndex, offsetBy: from)
    }

    func substring(_ toIndex: Int) -> String {
        let index = index(from: toIndex)
        return String(self[..<index])
    }

    /// Get all regex matches within a body of text
    func matches(for regex: String, in text: String) -> [String] {
        do {
            let regex = try NSRegularExpression(pattern: regex)
            let results = regex.matches(in: text,
                                        range: NSRange(text.startIndex..., in: text))
            return results.map {
                String(text[Range($0.range, in: text)!])
            }
        } catch let error {
            Log.fault("invalid regex: \(error.localizedDescription)")
            return []
        }
    }

    func abbreviatingWithTildeInPath() -> String {
        (self as NSString).abbreviatingWithTildeInPath
    }

    // MARK: Occurences

    /// Removes all `new-line` characters in a `String`
    /// - Returns: A String
    func removingNewLines() -> String {
        self.replacingOccurrences(of: "\n", with: "")
    }

    /// Removes all `space` characters in a `String`
    /// - Returns: A String
    func removingSpaces() -> String {
        self.replacingOccurrences(of: " ", with: "")
    }

    // MARK: Crypto

    /// Returns a MD5 encrypted String of the input String
    ///
    /// - Parameters:
    ///   - trim: If `true` the input string will be trimmed from whitespaces and new-lines. Defaults to `false`.
    ///   - caseSensitive: If `false` the input string will be converted to lowercase characters. Defaults to `true`.
    /// - Returns: A String in HEX format
    func md5(trim: Bool = false, caseSensitive: Bool = true) -> String {
        var string = self

        // trim whitespaces & new lines if specifiedå
        if trim { string = string.trimmingCharacters(in: .whitespacesAndNewlines) }

        // make string lowercased if not case sensitive
        if !caseSensitive { string = string.lowercased() }

        // compute the hash
        // (note that `String.data(using: .utf8)!` is safe since it will never fail)
        let computed = Insecure.MD5.hash(data: string.data(using: .utf8)!)

        // map the result to a hex string and return
        return computed.compactMap { String(format: "%02x", $0) }.joined()
    }

    /// Returns a SHA256 encrypted String of the input String
    ///
    /// - Parameters:
    ///   - trim: If `true` the input string will be trimmed from whitespaces and new-lines. Defaults to `false`.
    ///   - caseSensitive: If `false` the input string will be converted to lowercase characters. Defaults to `true`.
    /// - Returns: A String in HEX format
    func sha256(trim: Bool = false, caseSensitive: Bool = true) -> String {
        var string = self

        // trim whitespaces & new lines if specified
        if trim { string = string.trimmingCharacters(in: .whitespacesAndNewlines) }

        // make string lowercased if not case sensitive
        if !caseSensitive { string = string.lowercased() }

        // compute the hash
        // (note that `String.data(using: .utf8)!` is safe since it will never fail)
        let computed = SHA256.hash(data: string.data(using: .utf8)!)

        // map the result to a hex string and return
        return computed.compactMap { String(format: "%02x", $0) }.joined()
    }

    // MARK: Range

    // make string subscriptable with NSRange
    subscript(value: NSRange) -> Substring? {
        let upperBound = String.Index(utf16Offset: Int(value.upperBound), in: self)
        let lowerBound = String.Index(utf16Offset: Int(value.lowerBound), in: self)
        if upperBound <= self.endIndex {
            return self[lowerBound..<upperBound]
        } else {
            return nil
        }
    }

    // MARK: Version Control
    /// Percent-encodes a string to be URL-safe
    ///
    /// See https://useyourloaf.com/blog/how-to-percent-encode-a-url-string/ for more info
    /// - returns: An optional string, with percent encoding to match RFC3986
    func stringByAddingPercentEncodingForRFC3986() -> String? {
        let unreserved = "-._~/?"
        var allowed = CharacterSet.alphanumerics
        allowed.insert(charactersIn: unreserved)
        return addingPercentEncoding(withAllowedCharacters: allowed)
    }

    var bitbucketQueryParameters: [String: String] {
        let parametersArray = components(separatedBy: "&")
        var parameters = [String: String]()
        parametersArray.forEach { parameter in
            let keyValueArray = parameter.components(separatedBy: "=")
            let (key, value) = (keyValueArray.first, keyValueArray.last)
            if let key = key?.removingPercentEncoding, let value = value?.removingPercentEncoding {
                parameters[key] = value
            }
        }
        return parameters
    }
}
