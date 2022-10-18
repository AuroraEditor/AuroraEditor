//
//  GrammarJsonLoader.swift
//  
//
//  Created by TAY KAI QUAN on 28/9/22.
//

import Foundation

class GrammarJsonLoader {

    static let shared: GrammarJsonLoader = .init()

    private init() {} // prevent GrammarJsonLoader from being created anywhere else

    /// Function that, taking in a filename for a bundled tmlanguage JSON file, returns a ``Grammar`` from its contents
    /// - Parameter fileName: The name of the JSON file, not including the `.json` at the end
    /// - Returns: A ``Grammar`` representing the contents of the JSON, or nil if the given json is invalid.
    public func loadBundledJson(fileName: String) -> Grammar? { // TODO: Depreciate this and use loadJson:from:
        if let path = Bundle.main.path(forResource: fileName, ofType: "json") {
            let url = URL(fileURLWithPath: path)
            do {
                let data = try Data(contentsOf: url)
                return grammarFromJson(jsonStr: String(decoding: data, as: UTF8.self))
            } catch {
                Log.info(String(describing: error))
            }
        } else {
            Log.info("Json not found")
        }
        return nil
    }

    /// Function that, taking in a URL for a tmlanguage JSON file, returns a ``Grammar`` from its contents
    /// - Parameter url: The URL of the JSON file
    /// - Returns: A ``Grammar`` representing the contents of the JSON, or
    /// nil if the given URL cannot be read as a grammar json.
    public func loadJson(from url: URL) -> Grammar? {
        do {
            let data = try Data(contentsOf: url)
            return grammarFromJson(jsonStr: String(decoding: data, as: UTF8.self))
        } catch {
            Log.info(String(describing: error))
        }
        return nil
    }

    /// Generates a ``Grammar`` class from a JSON string, if possible.
    ///
    /// There are three main types of ``Pattern`` that we need to decode:
    /// - ``IncludeRulePattern``, which maps to those patterns with a single `"include": ""` key
    /// - ``Rule``, which is a superclass representing:
    ///   - ``BeginEndRule``:  Patterns with beginning and end segments
    ///   - ``MatchRule``:  Patterns with only a single match
    /// - ``Capture``:  Arrays of patterns with a single `"name": ""` key
    ///
    /// Along with that are ``Repository``s, which seem to be groups of ``Pattern``s
    ///
    /// - Parameter jsonStr: A String representing the JSON data
    /// - Returns: A ``Grammar`` class if it succeeded, `nil` otherwise.
    public func grammarFromJson(jsonStr: String) -> Grammar? {

        guard let jsonData = jsonStr.data(using: .utf8),
              let json = try? JSONSerialization.jsonObject(with: jsonData, options: []) as? [String: Any]
        else {
            Log.info("Failed to load json")
            return nil
        }

        // make sure the scope has a name
        guard let scopeName = json["scopeName"] as? String else {
            Log.info("Json does not contain `scopeName` required data")
            return nil
        }

        return Grammar(scopeName: scopeName,
                       fileTypes: [],
                       patterns: patternsFromJsonArray(jsonArray: json["patterns"] as? [[String: Any]]),
                       foldingStartMarker: nil,
                       foldingStopMarker: nil,
                       repository: repositoryFromJsonDict(jsonDict: json["repository"] as? [String: [String: Any]]))
    }

    /// Given an array of `[String: Any]` values, returns an array of ``Pattern``s
    /// - Parameter jsonArray: An array of `[String: Any]` values
    /// - Returns: An array of ``Pattern``s with contents from the json array, or `[]` if an error occurred
    func patternsFromJsonArray(jsonArray: [[String: Any]]?) -> [Pattern] {
        guard let jsonArray = jsonArray else { return [] }
        var result: [Pattern] = []
        for pattern in jsonArray {
            if let pattern = patternFromJson(json: pattern, keyName: "") { // these don't have names
                result.append(pattern)
            }
        }
        return result
    }

    /// Given a String-keyed dictionary of `[String: Any]` values, returns a dictionary of ``Pattern``s
    /// - Parameter jsonDict: An array of `[String: Any]` values
    /// - Returns: A dictionary of ``Pattern``s with contents from the json dictionary, or `[:]` if an error occurred
    func patternsFromJsonDict(jsonDict: [String: [String: Any]]?) -> [String: Pattern]? {
        guard let jsonDict = jsonDict else { return nil }
        var patterns: [String: Pattern] = [:]
        for (name, pattern) in jsonDict {
            if let realPattern = patternFromJson(json: pattern, keyName: name) {
                patterns[name] = realPattern
            }
            if let repository = pattern["repository"] as? [String: [String: Any]],
               let newPatterns = patternsFromJsonDict(jsonDict: repository) {
                for newPattern in newPatterns {
                    patterns[newPattern.key] = newPattern.value
                }
            }
        }
        return patterns
    }

    /// Given a dictionary of `[String: Any]` values, returns a ``Repository``, or `nil` if not possible
    /// - Parameter jsonDict: An array of `[String: Any]` values
    /// - Returns: A ``Repository`` if the given jsonDict is a valid Repository, or `nil` otherwise
    func repositoryFromJsonDict(jsonDict: [String: [String: Any]]?) -> Repository? {
        guard let jsonDict = jsonDict else { return nil }
        var patterns: [String: Pattern] = [:]
        for (name, pattern) in jsonDict {
            if let realPattern = patternFromJson(json: pattern, keyName: name) {
                patterns[name] = realPattern
            }
            if let repository = pattern["repository"] as? [String: [String: Any]],
               let newPatterns = patternsFromJsonDict(jsonDict: repository) {
                for newPattern in newPatterns {
                    patterns[newPattern.key] = newPattern.value
                }
            }
        }
        return Repository(patterns: patterns)
    }

    /// Given a JSON dictionary and the name of the dictionary, returns a ``Pattern`` if the JSON's keys matches the
    /// properties of any ``Pattern``
    /// - Parameters:
    ///   - json: The JSON dictionary to turn into a pattern
    ///   - keyName: The name of the pattern, used as a fallback.
    /// - Returns: A ``Pattern`` if the JSON's data matches that of a ``Pattern`` type, `nil` if not.
    func patternFromJson(json: [String: Any], keyName: String) -> Pattern? {
        // if the json contains a `begin`, `beginCaptures`, `end`,
        // `endCaptures`, and `patterns` field, it is a BeginEndRule
        if let begin = json["begin"] as? String,
           let end = json["end"] as? String {
            let beginCaptures = json["beginCaptures"] as? [String: [String: String]]
            let endCaptures = json["endCaptures"] as? [String: [String: String]]
            let contentName = json["contentName"] as? String

            let patterns = json["patterns"] as? [[String: Any]]
            let name = json["name"] as? String

            return BeginEndRule(name: name ?? keyName,
                                begin: begin,
                                end: end,
                                contentName: contentName,
                                patterns: patternsFromJsonArray(jsonArray: patterns),
                                beginCaptures: jsonDictToCaptures(captures: beginCaptures),
                                endCaptures: jsonDictToCaptures(captures: endCaptures))
        }

        // if the json contains a `match` and `name` field, it is a MatchRule
        if let match = json["match"] as? String {
            let name = json["name"] as? String
            let captures = json["captures"] as? [String: [String: Any]]

            return MatchRule(name: name ?? keyName, match: match, captures: jsonDictToCaptures(captures: captures))
        }

        // if the json contains a `include` field, it is a IncludeRulePattern
        if let include = json["include"] as? String {
            return IncludeRulePattern(include: include)
        }

        // if the json just contains a `pattern`, it is a Capture
        if let pattern = json["patterns"] as? [[String: Any]] {
            return Capture(name: keyName.isEmpty ? nil : keyName, patterns: patternsFromJsonArray(jsonArray: pattern))
        }

        // if none of the above, return nil
        Log.info("Json \(keyName) with keys \(json.keys) did not match anything")
        return nil
    }

    /// Taking in a JSON dictionary, it returns an array of `String` values.
    ///
    /// The expected format of this JSON is:
    /// ```
    /// {
    ///     "0": {
    ///         "name": "" // name
    ///     }
    ///     // ....
    /// }
    /// ```
    /// - Parameter captures: A JSON dictionary matching the above format
    /// - Returns: An array of strings, representing the values of all the `name` fields in the dictionary
    func jsonDictToStringArray(captures: [String: [String: String]]?) -> [String] {
        guard let captures = captures else { return [] }
        var result: [String] = []
        for captureIndex in captures.keys.sorted(by: { $0 < $1 }) { // sort in numerical order
            if let name = captures[captureIndex]?["name"] {
                result.append(name)
            }
        }
        return result
    }

    /// Turns a JSON dictionary into an array of ``Capture``s,
    ///
    /// The expected format of this JSON is:
    /// ```
    /// {
    ///     "0": {
    ///         "patterns": [/*...*/] // the array of Patterns
    ///     }
    ///     // ....
    /// }
    /// ```
    /// - Parameter captures: A JSON dictionary
    /// - Returns: An array of ``Capture``s containing ``Pattern``s created from the `patterns` field of the json
    func jsonDictToCaptures(captures: [String: [String: Any]]?) -> [Capture] {
        guard let captures = captures else { return [] }
        var result: [Capture] = []
        for captureIndex in captures.keys.sorted(by: { $0 < $1 }) { // sort in numerical order
            if let name = captures[captureIndex]?["name"] as? String {
                result.append(Capture(name: name))
            } else if let patterns = captures[captureIndex]?["patterns"] as? [[String: Any]] {
                result.append(Capture(patterns: patternsFromJsonArray(jsonArray: patterns)))
            }
        }
        return result
    }
}

// MARK: Loading from file extension

extension GrammarJsonLoader {

    /// A dictionary mapping the standard file type to a ``LanguageFile`` instance, that holds data about the
    /// language grammar, including the file extensions that would trigger it and the name of the grammar file.
    ///
    /// Extensions would use ``addLanguageFiles(language:grammar:fileExtensions:)``
    /// to specify the file extensions for files that use that grammar, and the name of the grammar file.
    private(set) static var languageFiles: [String: LanguageFile] = [
        // swiftlint:disable:next swiftlint_file_disabling
        // swiftlint:disable line_length
        "text": LanguageFile(fileExtensions: ["txt", "", "text"], grammar: { .default }),
        "swift": LanguageFile(fileExtensions: ["swift"], grammar: { GrammarJsonLoader.shared.loadBundledJson(fileName: "swift.tmLanguage") }),
        "typescript": LanguageFile(fileExtensions: ["ts"], grammar: { GrammarJsonLoader.shared.loadBundledJson(fileName: "typeScript.tmLanguage") }),
        "json": LanguageFile(fileExtensions: ["json"], grammar: { GrammarJsonLoader.shared.loadBundledJson(fileName: "JSON.tmLanguage") }),
        "jsonc": LanguageFile(fileExtensions: ["jsonc"], grammar: { GrammarJsonLoader.shared.loadBundledJson(fileName: "JSONC.tmLanguage") }),
        "docker": LanguageFile(fileExtensions: ["docker"], grammar: { GrammarJsonLoader.shared.loadBundledJson(fileName: "docker.tmLanguage") }),
        "css": LanguageFile(fileExtensions: ["css"], grammar: { GrammarJsonLoader.shared.loadBundledJson(fileName: "css.tmLanguage") }),
        "htmlderiv": LanguageFile(fileExtensions: [], grammar: { GrammarJsonLoader.shared.loadBundledJson(fileName: "html-derivative.tmLanguage") }),
        "html": LanguageFile(fileExtensions: ["html"], grammar: { GrammarJsonLoader.shared.loadBundledJson(fileName: "html.tmLanguage") }),
        "javascript": LanguageFile(fileExtensions: ["js"], grammar: { GrammarJsonLoader.shared.loadBundledJson(fileName: "JavaScript.tmLanguage") }),
        "javascriptreact": LanguageFile(fileExtensions: [], grammar: { GrammarJsonLoader.shared.loadBundledJson(fileName: "JavaScriptReact.tmLanguage") }),
        "php": LanguageFile(fileExtensions: ["php"], grammar: { GrammarJsonLoader.shared.loadBundledJson(fileName: "php.tmLanguage") }),
        "ruby": LanguageFile(fileExtensions: ["ruby"], grammar: { GrammarJsonLoader.shared.loadBundledJson(fileName: "ruby.tmLanguage") })
        // swiftlint:enable line_length
    ]

    /// Adds a `String` ``LanguageFile`` pair to the index of languages, overriding any
    /// language that was preexisting sharing the same `language` name.
    /// - Parameters:
    ///   - language: The name of the language to add, eg. "html". Use lowercase.
    ///   - grammar: A closure that returns an optional grammar, called when the grammar for the language is needed.
    ///   - fileExtensions: An array of file extensions that the grammar applies to.
    static func addLanguageFiles(language: String,
                                 grammar: @escaping () -> Grammar?,
                                 fileExtensions: [String]) {
        languageFiles[language] = LanguageFile(fileExtensions: Set(fileExtensions), grammar: grammar)
    }

    /// Modifies a property in an existing language
    /// - Parameters:
    ///   - language: The name of the language to modify
    ///   - grammar: A closure that returns an optional grammar. Leave as nil to leave it as it is.
    ///   - fileExtensions: An array of file extensions that the grammar applies to. Leave as nil to leave it as it is.
    /// - Returns: True if something was replaced, false otherwise (language not found or didn't change anything)
    static func modifyLanguageProperty(language: String,
                                       grammar: (() -> Grammar?)? = nil,
                                       fileExtensions: [String]? = nil) -> Bool {
        // ensure at least one property is non-nil, and that the language exists.
        guard languageFiles[language] != nil &&
              (grammar != nil || fileExtensions != nil)
        else { return false }

        // replace the properties
        if let grammar = grammar {
            languageFiles[language]?.grammar = grammar
        }
        if let fileExtensions = fileExtensions {
            languageFiles[language]?.fileExtensions = Set(fileExtensions)
        }

        return true
    }

    /// The language data for a particular language
    /// - Parameter language: The name of the language
    /// - Returns: The data for the language, a ``LanguageFile``
    static func languageFileFor(language: String) -> LanguageFile? { languageFiles[language] }

    struct LanguageFile {
        var fileExtensions: Set<String>
        var grammar: () -> Grammar? // NOTE: grammar is a closure to avoid creating too many Grammars
    }

    static func grammarFor(extension fileExtension: String) -> Grammar {
        // see if one is cached already
        if let grammar = loadedGrammars[fileExtension] {
            return grammar
        }

        // iterate over all supported languages, and see which one offers the grammar.
        for (_, languageFile) in languageFiles {
            if languageFile.fileExtensions.contains(fileExtension.lowercased()),
               let grammar = languageFile.grammar() {
                loadedGrammars[fileExtension] = grammar
                return grammar
            }
        }

        // by default, read it as plaintext.
        return languageFiles["text"]!.grammar()!
    }

    private static var loadedGrammars: [String: Grammar] = [:]
}
