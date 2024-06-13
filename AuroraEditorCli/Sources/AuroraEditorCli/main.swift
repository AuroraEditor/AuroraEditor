//
//  main.swift
//  Aurora Editor
//
//  Created by Ben Koska on 14.06.22.
//  Copyright © 2023 Aurora Company. All rights reserved.
//

import Foundation

/// Convert to absolute path
/// 
/// - Parameter path: The path to convert
/// - Returns: The absolute path
func convertToAbsolutePath(_ path: String) -> String {
    let nsString = NSString(string: path)
    if nsString.isAbsolutePath {
        return nsString.standardizingPath
    }

    return String(
        URL(
            string: path,
            relativeTo: URL(
                fileURLWithPath: FileManager.default.currentDirectoryPath
            )
        )?.pathComponents.joined(separator: "/").dropFirst(1) ?? ""
    )
}

/// Open AuroraEditor
/// 
/// - Parameter paths: The paths to open
func openApp(paths: [String]? = nil) {
    let task = Process()
    task.launchPath = "/usr/bin/open" // This should be the same on all installations of MacOS

    task.arguments = ["-a", "AuroraEditor"]

    if let paths = paths {
        task.arguments?.append("--args")
        for path in paths {
            task.arguments?.append("--open")
            task.arguments?.append(convertToAbsolutePath(path))
        }
    }

    task.launch()
}

// If no arguments are passed, open the app
if CommandLine.arguments.count < 2 {
    // Open the app without any arguments
    openApp()
} else {
    // If arguments are passed, open the app with the arguments
    openApp(paths: Array(CommandLine.arguments.dropFirst(1)))
}
