//
//  GrammerFromJson.swift
//  
//
//  Created by TAY KAI QUAN on 28/9/22.
//

import Foundation

/// Function that, taking in a filename for a tmlanguage JSON file, returns a ``Grammar`` from its contents
/// - Parameter fileName: The name of the JSON file, not including the `.json` at the end
/// - Returns: A ``Grammar`` representing the contents of the JSON, or nil if the given json is invalid.
public func loadJson(fileName: String) -> Grammar? {
    if let path = Bundle.main.path(forResource: fileName, ofType: "json") {
        let url = URL(fileURLWithPath: path)
        do {
            let data = try Data(contentsOf: url)
            return grammarFromJson(jsonStr: String(decoding: data, as: UTF8.self))
        } catch {
            log(String(describing: error))
        }
    } else {
        log("Json not found")
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
        log("Failed to load json")
        return nil
    }

    // make sure the scope has a name
    guard let scopeName = json["scopeName"] as? String else {
        log("Json does not contain `scopeName` required data")
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
    // if the json contains a `begin`, `beginCaptures`, `end`, `endCaptures`, and `patterns` field, it is a BeginEndRule
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
    if let match = json["match"] as? String { // TODO: Get matches with a `capture` array instead of a `name` working
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
    log("Json \(keyName) with keys \(json.keys) did not match anything")
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

public var loadedGrammer: Grammar {
    if let loadedGrammerBackend = loadedGrammerBackend {
        return loadedGrammerBackend
    } else {
        loadedGrammerBackend = loadJson(fileName: "swift.tsLanguage")
        return loadedGrammerBackend!
    }
}

private var loadedGrammerBackend: Grammar?

func log(_ str: String) { // TODO: Remove this
    print(str) // swiftlint:disable:this disallow_print
}
