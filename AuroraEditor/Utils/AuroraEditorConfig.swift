//
//  AuroraEditorConfig.swift
//  Aurora Editor
//
//  Created by Wesley de Groot on 10/02/2024.
//  Copyright © 2024 Aurora Company. All rights reserved.
//

import Foundation

class AuroraEditorConfig {
    /// .editorconfig keys
    enum EditorConfigKeys: String {
        /// Indentation Size (in single-spaced characters)
        case indent_style
        // swiftlint:disable:previous identifier_name

        /// Indentation Size (in single-spaced characters)
        case indent_size
        // swiftlint:disable:previous identifier_name

        /// Width of a single tabstop character
        case tab_width
        // swiftlint:disable:previous identifier_name

        /// Line ending file format (Unix, DOS, Mac)
        case end_of_line
        // swiftlint:disable:previous identifier_name

        // swiftlint:disable:next line_length
        /// File character encoding ([See Character Set Support](https://github.com/editorconfig/editorconfig/wiki/Character-Set-Support).)
        case charset

        /// Denotes whether whitespace is removed from the end of lines
        case trim_trailing_whitespace
        // swiftlint:disable:previous identifier_name

        /// Denotes whether file should end with a newline
        case insert_final_newline
        // swiftlint:disable:previous identifier_name

        /// Forces hard line wrapping after the amount of characters specified.
        /// off to turn off this feature (use the editor settings).
        case max_line_length
        // swiftlint:disable:previous identifier_name

        // EXPERIMENTAL/NON-DEFAULT KEYS
        /// Denotes preferred quoting style for string literals (for languages that support multiple quote styles)
        case quote_type
        // swiftlint:disable:previous identifier_name

        /// Denotes the include paths of header files for some languages.
        /// Could be used by syntax checkers and compilers inside editors.
        case c_include_path
        // swiftlint:disable:previous identifier_name

        /// Denotes the `CLASSPATH` used by the Java source files.
        /// Could be used by some Java syntax checkers and compilers inside editors.
        case java_class_path
        // swiftlint:disable:previous identifier_name

        /// Denotes whether the left part of the curly bracket should be on the next line or not
        case curly_bracket_next_line
        // swiftlint:disable:previous identifier_name

        /// Denotes whether spaces should be present around arithmetic and boolean operators
        case spaces_around_operatorsm
        // swiftlint:disable:previous identifier_name

        /// Denotes how spaces should be around brackets and parentheses:
        /// no space, only inside the brackets, only outside the brackets, or at the both side of brackets
        case spaces_around_brackets
        // swiftlint:disable:previous identifier_name

        /// Denotes the [style for using curly](https://en.wikipedia.org/wiki/Indent_style)
        /// braces in code blocks
        case indent_brace_style
        // swiftlint:disable:previous identifier_name

        /// Denotes the number of imports required before multiple imports are
        /// automatically collapsed to a wildcard (or a wildcard is automatically expanded to explicit imports)
        case wildcard_import_limit
        // swiftlint:disable:previous identifier_name

        /// Denotes the continuation indent size. Useful to distinguish code blocks versus continuation lines
        case continuation_indent_size
        // swiftlint:disable:previous identifier_name

        /// Denotes the block_comment or line_comment character to mark a block or each line as comment.
        /// Some languages require # prepended on each line, others // or ;.
        /// Some have specific block start markers and end markers such as /* and */ and <!-- and --!>
        case block_comment, line_comment, block_comment_start, block_comment_end
        // swiftlint:disable:previous identifier_name
    }

    var parsed: [String: [String: Any]]? = [:]

    var defaults: [String: [String: Any]] = [
        "*": [
            "indent_style": "space",
            "indent_size": "4",
            "tab_width": "4",
            "end_of_line": "lf",
            "charset": "utf8",
            "trim_trailing_whitespace": "true",
            "insert_final_newline": "true",
            "max_line_length": "off"
        ]
    ]

    init(fromPath: String) {
        if let configFile = findEditorConfig(fromPath: fromPath),
           let configData = FileManager.default.contents(atPath: configFile),
           let configINI = String(data: configData, encoding: .utf8) {
            let parsed = AuroraINIParser(ini: configINI).parse()
            Log.info("INI=\(configFile)")
            Log.info(parsed)
            self.parsed = parsed
        }
    }

    /// Get value for type
    /// - Parameters:
    ///   - value: value type
    ///   - for: for type
    public func get(value: EditorConfigKeys, for file: String = "*") -> String {
        if let value = getKeyNameFor(parsed, file: file)?[value.rawValue] as? String {
            return value
        }

        if let value = parsed?["*"]?[value.rawValue] as? String {
            return value
        }

        if let value = getKeyNameFor(defaults, file: file)?[value.rawValue] as? String {
            return value
        }

        if let value = defaults["*"]?[value.rawValue] as? String {
            return value
        }

        Log.error("There is no value for \(value.rawValue) for file \(file)")
        return ""
    }

    private func shouldInvert(_ value: Bool, inverted: Bool) -> Bool {
        return inverted ? !value : value
    }

    private func getKeyNameFor(_ inDict: [String: [String: Any]]?, file: String) -> [String: Any]? {
        var invert = false

        if let inDict = inDict {
            for (pattern, values) in inDict {
                if pattern.hasPrefix("!") {
                    invert = true
                }

                if pattern.contains("**") {
                    Log.info("** is not (yet) supported")
                    continue
                } else if pattern.hasPrefix("*.") {
                    let search = pattern.replacingOccurrences(of: "*.", with: "")

                    if pattern.contains("{") && pattern.contains("}") {
                        if let noOpen = pattern.split(separator: "{").last,
                           let noClose = noOpen.split(separator: "}").first {
                            var extensionList = noClose.split(separator: ",")

                            for fileExtension in extensionList where shouldInvert(
                                file.hasSuffix(fileExtension),
                                inverted: invert
                            ) {
                                return values
                            }
                        }
                    }

                    if file.hasSuffix(search) {
                        return values
                    }
                } else {
                    if file.hasSuffix(pattern) {
                        return values
                    }
                }
            }
        }

        return nil
    }

    private func findEditorConfig(fromPath: String) -> String? {
        let components = fromPath.components(separatedBy: "/")
        for number in stride(from: 0, to: components.count, by: 1) {
            var components = fromPath.components(separatedBy: "/")
            for _ in stride(from: 0, to: number, by: 1) {
                components.removeLast()
            }

            var temporaryPath = components.joined(separator: "/")
            temporaryPath += "/.editorconfig"

            if FileManager.default.fileExists(atPath: temporaryPath) {
                return temporaryPath
            }
        }

        return nil
    }
}
