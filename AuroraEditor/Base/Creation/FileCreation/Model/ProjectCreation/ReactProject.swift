//
//  ReactProject.swift
//  AuroraEditor
//
//  Created by Nanashi Li on 2022/09/05.
//  Copyright © 2022 Aurora Company. All rights reserved.
//

import AppKit

func checkReactInstallation() throws -> Bool {
    let doesExist = try ShellClient.live().run("npm view react version")

    if !doesExist.contains("command not found") {
        return false
    }

    return true
}

func installReactWeb(completionHandler: @escaping (Result<String, Error>) throws -> Void) throws {
    if try checkBrewInstallation() {
        if try !checkNpmInstallation() {
            try installNpmPrompt(completionHandler: { completion in
                switch completion {
                case .success:
                    try ShellClient.live().run("npm i react")
                    try completionHandler(.success("Successfully installed react"))
                case .failure:
                    try failureToInstall(installComponent: "node")

                }
            })
        } else {
            try ShellClient.live().run("npm i react")
            try completionHandler(.success("Successfully installed react"))
        }
    }
}

// TODO: Make sure to check if project name uses capital letters
//
// Cannot create a project named "TestProject" because of npm naming restrictions:
//
// * name can no longer contain capital letters
//
// Please choose a different project name.
func createReactWebProject(auroraDirectory: URL,
                           projectName: String,
                           completionHandler: @escaping (Result<String, Error>) throws -> Void) throws {
    try ShellClient.live().run(
        "cd \(auroraDirectory.relativePath.escapedWhiteSpaces());npx create-react-app \(projectName)"
    )
    Log.debug("cd \(auroraDirectory.relativePath.escapedWhiteSpaces());npx create-react-app@latest \(projectName)")
    try completionHandler(.success("Created successfully"))
//    if try checkReactInstallation() {
//        try ShellClient.live().run(
//            "cd \(auroraDirectory.relativePath.escapedWhiteSpaces());npx create-react-app \(projectName)"
//        )
//        try completionHandler(.success("Created successfully"))
//    } else {
//        let alert = NSAlert()
//        alert.messageText = "Couldn't seem to find \"react\" installed on your system."
//        alert.informativeText = "Would you like to let AuroraEditor install \"react\" for you?"
//        alert.addButton(withTitle: "Continue")
//        alert.addButton(withTitle: "Cancel")
//        if alert.runModal() == .alertFirstButtonReturn {
//            try installReactWeb(completionHandler: { completion in
//                switch completion {
//                case .success:
//                    try ShellClient.live().run(
//                        "cd \(auroraDirectory.relativePath.escapedWhiteSpaces()); npx create-react-app \(projectName)"
//                    )
//                    try completionHandler(.success("Created successfully"))
//                case .failure:
//                    try failureToInstallNpmPackage(installComponent: "react")
//                    try completionHandler(.failure(ReactProject.failedToCreateProject))
//                }
//            })
//        }
//    }
}

func createReactNativeProject(auroraDirectory: URL, projectName: String) throws {
    if try checkReactInstallation() {
        try ShellClient.live().run(
            "cd \(auroraDirectory.relativePath.escapedWhiteSpaces()); create-react-native-app \(projectName)"
        )
    } else {
        let alert = NSAlert()
        alert.messageText = "Couldn't seem to find \"react\" installed on your system."
        alert.informativeText = "Would you like to let AuroraEditor install \"react\" for you?"
        alert.addButton(withTitle: "Continue")
        alert.addButton(withTitle: "Cancel")
        if alert.runModal() == .alertFirstButtonReturn {
            try installReactNative(completionHandler: { completion in
                switch completion {
                case .success:
                    try ShellClient.live().run(
                        "cd \(auroraDirectory.relativePath.escapedWhiteSpaces());create-react-native-app \(projectName)"
                    )
                case .failure:
                    try failureToInstallNpmPackage(installComponent: "create-react-native-app")
                }
            })
        }
    }
}

func installReactNative(completionHandler: @escaping (Result<String, Error>) throws -> Void) throws {
    if try checkBrewInstallation() {
        if try !checkNpmInstallation() {
            try installNpmPrompt(completionHandler: { completion in
                switch completion {
                case .success:
                    try ShellClient.live().run("npm i -g create-react-native-app")
                    try completionHandler(.success("Successfully installed react"))
                case .failure:
                    try failureToInstall(installComponent: "create-react-native-app")

                }
            })
        } else {
            try ShellClient.live().run("npm i -g create-react-native-app")
            try completionHandler(.success("Successfully installed react"))
        }
    }
}
enum ReactProject: String, Error {
    case failedToCreateProject = "Failed to create project"
}
