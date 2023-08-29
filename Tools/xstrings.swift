//
//  xstrings.swift
//  Aurora Editor
//
//  Created by Nanashi Li on 2023/01/23.
//  Copyright © 2023 Aurora Company. All rights reserved.
//

import Foundation

// TODO: Improve the process of this, by allowing to add the strings to the localisation file
// instead of logging them
func processFile(_ path: String, keyPrefix: String?) {
    guard let file = freopen(path, "r", stdin) else {
        fputs("Failed to open file.\n", stderr)
        return
    }
    defer {
        fclose(file)
    }

    let pattern = #""(?:\.|[^"])*""#

    do {
        let regex = try NSRegularExpression(pattern: pattern)

        // TODO: Rather get the file name and the first two words and use that as a key
        var keyCount = 0
        let keyPrefix = keyPrefix ?? "key"

        // swiftlint:disable:this disallow_print
        print()

        while let line = readLine() {
            let range = NSRange(location: 0, length: line.utf16.count)

            regex.enumerateMatches(in: line, range: range) { result, _, _ in
                guard let match = result,
                      let range = Range(match.range, in: line) else { return }
                // swiftlint:disable:this disallow_print
                print("\"\(keyPrefix).\(keyCount)\" = \(line[range]);")
                keyCount += 1
            }
        }
    } catch {
        // swiftlint:disable:this disallow_print
        print("Failure to run")
    }
}

func run() {
    guard CommandLine.arguments.count > 1 else {
        fputs("Syntax: xstrings <filename> [<key prefix>]\n", stderr)
        return
    }

    let keyPrefix: String? = CommandLine.arguments.count > 2 ? CommandLine.arguments[2] : nil
    processFile(CommandLine.arguments[1], keyPrefix: keyPrefix)
}

run()
