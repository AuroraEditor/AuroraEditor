//
//  main.swift
//  Aurora Editor
//
//  Created by Ben Koska on 14.06.22.
//  Copyright © 2023 Aurora Company. All rights reserved.
//

import Foundation

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

if CommandLine.arguments.count < 2 {
    openApp()
} else {
    openApp(paths: Array(CommandLine.arguments.dropFirst(1)))
}
