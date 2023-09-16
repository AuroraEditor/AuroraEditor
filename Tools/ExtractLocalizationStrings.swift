//
//  ExtractLocalizationStrings.swift
//  Aurora Editor
//
//  Created by Nanashi Li on 2023/01/23.
//  Copyright © 2023 Aurora Company. All rights reserved.
//

import Foundation

/**
   Generates a concise key based on string content without enclosing quotation marks.

   - Parameter from: The input string to generate the key from.
   - Returns: A concise key based on the input string.
*/
func generateConciseKey(from string: String) -> String {
    // Remove enclosing quotation marks from the extracted string if present.
    var cleanedString = string
    if cleanedString.hasPrefix("\"") && cleanedString.hasSuffix("\"") {
        cleanedString = String(cleanedString.dropFirst().dropLast())
    }

    // Split the cleaned string into words, take the first two words, and concatenate them.
    let words = cleanedString.components(separatedBy: .whitespaces)
    if words.count >= 2 {
        return words[0] + "_" + words[1]
    } else {
        // If there are fewer than two words, use the entire cleaned string.
        return cleanedString.lowercased()
    }
}

/**
   Extracts localized strings from a single file and replaces Swift string interpolations.

   - Parameters:
      - filePath: The path to the file to extract strings from.
      - localizationDict: A dictionary to store extracted key-value pairs.
      - keyPrefix: A prefix to prepend to the generated keys.
*/
func extractStringsFromFile(_ filePath: String, localizationDict: inout [String: String], keyPrefix: String) {
    let pattern = #""(?!\\\())[\\p{L}\\p{M}\\p{N}\\p{P}\\p{Zs}\\p{Sc}\\p{Sk}\\p{So}]+""#

    do {
        let regex = try NSRegularExpression(pattern: pattern)
        let fileContents = try String(contentsOfFile: filePath, encoding: .utf8)

        for line in fileContents.components(separatedBy: .newlines) {
            let range = NSRange(location: 0, length: line.utf16.count)

            regex.enumerateMatches(in: line, range: range) { result, _, _ in
                guard let match = result, let range = Range(match.range, in: line) else { return }
                var extractedString = String(line[range])

                // Check if the extracted string matches the pattern for multiple periods.
                if extractedString.range(of: #"^[^.]+(\.[^.]+){2,}$"#, options: .regularExpression) == nil {
                    // Replace Swift string interpolations (\(string)) with %@.
                    extractedString = extractedString.replacingOccurrences(of: #"\\?\([^)]+\)"#, with: "%@", options: .regularExpression)

                    // Generate a concise key based on a portion of the extracted string.
                    let key = "\(keyPrefix).\(generateConciseKey(from: extractedString))"
                    localizationDict[key] = extractedString
                }
            }
        }
    } catch {
        print("Error processing file: \(filePath)")
    }
}

/**
   Extracts localized strings from all Swift source files in the project.

   - Parameters:
      - projectDirectory: The path to the project directory.
      - localizationDict: A dictionary to store extracted key-value pairs.
      - keyPrefix: A prefix to prepend to the generated keys.
*/
func extractStringsFromProject(projectDirectory: String, localizationDict: inout [String: String], keyPrefix: String) {
    let fileManager = FileManager.default

    do {
        let projectFiles = try fileManager.contentsOfDirectory(atPath: projectDirectory)

        for file in projectFiles {
            let filePath = "\(projectDirectory)/\(file)"

            // Check if the file is a Swift source code file.
            if file.hasSuffix(".swift") {
                // Process the file to extract strings and store them in localizationDict.
                extractStringsFromFile(filePath, localizationDict: &localizationDict, keyPrefix: keyPrefix)
            }
        }
    } catch {
        print("Error reading project directory: \(projectDirectory)")
    }
}

/**
   Creates or opens a Localizable.strings file for a specific localization.

   - Parameters:
      - localizationDirectoryPath: The path to the Localization directory.
      - localizationFileName: The name of the localization file.
      - localizationSubdirectory: The name of the localization subdirectory.

   - Returns: A file handle for the opened or created localization file.
*/
func createLocalizationFile(localizationDirectoryPath: String, localizationFileName: String, localizationSubdirectory: String) -> FileHandle? {
    let localizationFilePath = "\(localizationDirectoryPath)/\(localizationSubdirectory)/\(localizationFileName)"

    do {
        // Create or open the localization file.
        if !FileManager.default.fileExists(atPath: localizationFilePath) {
            FileManager.default.createFile(atPath: localizationFilePath, contents: nil, attributes: nil)
        }

        return try FileHandle(forWritingTo: URL(fileURLWithPath: localizationFilePath))
    } catch {
        print("Error creating/opening localization file: \(localizationFilePath)")
        return nil
    }
}

/**
   Appends localized strings to a Localizable.strings file, replacing existing keys and maintaining alphabetical order.

   - Parameters:
      - fileHandle: The file handle for the localization file.
      - localizationDict: A dictionary containing key-value pairs to append.
      - localizationFilePath: The path to the localization file.
*/
func appendToLocalizationFile(fileHandle: FileHandle?, localizationDict: [String: String], localizationFilePath: String) {
    guard let fileHandle = fileHandle else { return }

    do {
        // Read the existing contents of the Localizable.strings file.
        var existingContents = try String(contentsOfFile: localizationFilePath, encoding: .utf8)
        var existingLines = existingContents.components(separatedBy: .newlines)

        for (key, value) in localizationDict {
            // Remove any existing key-value pair with the same key.
            existingLines = existingLines.filter { !$0.hasPrefix("\"\(key)\" =") }

            // Create the new key-value pair in the required format.
            let line = "\"\(key)\" = \(value);"

            // Find the correct index to insert the new line while maintaining alphabetical order.
            var insertionIndex = 0
            for (index, existingLine) in existingLines.enumerated() {
                if existingLine > line {
                    insertionIndex = index
                    break
                }
            }

            // Insert the new line at the determined index.
            existingLines.insert(line, at: insertionIndex)
        }

        // Join the updated lines back together.
        existingContents = existingLines.joined(separator: "\n")

        // Write the updated contents back to the localization file.
        if let data = existingContents.data(using: .utf8) {
            fileHandle.truncateFile(atOffset: 0)
            fileHandle.write(data)
        }

        fileHandle.closeFile()
    } catch {
        print("Error appending to localization file: \(localizationFilePath)")
    }
}

/**
   Main function to run the localization string extraction process.
*/
func run() {
    guard CommandLine.arguments.count > 3 else {
        // Print usage instructions if incorrect command-line arguments are provided.
        fputs("Syntax: xstrings <project_directory> <output_path> <key_prefix>\n", stderr)
        return
    }

    // Read the project directory, output path, and key prefix from command-line arguments.
    let projectDirectory = CommandLine.arguments[1]
    let outputPath = CommandLine.arguments[2]
    let keyPrefix = CommandLine.arguments[3]

    // Extract localized strings from the project directory.
    var localizationDict: [String: String] = [:]
    extractStringsFromProject(projectDirectory: projectDirectory, localizationDict: &localizationDict, keyPrefix: keyPrefix)

    // Determine the path to the Localization directory within the output path.
    let localizationDirectoryPath = "\(outputPath)"

    do {
        // Create the Localization directory if it doesn't exist.
        try FileManager.default.createDirectory(atPath: localizationDirectoryPath, withIntermediateDirectories: true, attributes: nil)

        // Determine the available localizations (subdirectories) within the Localization directory.
        let localizationSubdirectories = try FileManager.default.contentsOfDirectory(atPath: localizationDirectoryPath)

        for localizationSubdirectory in localizationSubdirectories {
            let localizationFileName = "Localizable.strings"

            // Create or open the Localizable.strings file for the current localization.
            if let fileHandle = createLocalizationFile(localizationDirectoryPath: localizationDirectoryPath, localizationFileName: localizationFileName, localizationSubdirectory: localizationSubdirectory) {
                // Append localized strings to the Localizable.strings file, replacing existing keys.
                appendToLocalizationFile(fileHandle: fileHandle, localizationDict: localizationDict, localizationFilePath: "\(localizationDirectoryPath)/\(localizationSubdirectory)/\(localizationFileName)")
            }
        }
    } catch {
        print("Error: \(error)")
    }
}

// Entry point: Run the localization string extraction process.
//
// Run Command: swift ExtractLocalizationStrings.swift <project_directory> <output_path> <key_prefix>
run()
