//
//  ProjectValidationCheck.swift
//  AuroraEditor
//
//  Created by Nanashi Li on 2022/09/05.
//  Copyright © 2022 Aurora Company. All rights reserved.
//

import AppKit

func checkBrewInstallation() throws -> Bool {
    let doesExist = try ShellClient.live().run("which -s brew")

    if doesExist.contains("command not found") {
        try installBrewPrompt()
        return false
    }

    return true
}

func checkNpmInstallation() throws -> Bool {
    let doesExist = try ShellClient.live().run("which -s npm")

    if doesExist.contains("command not found") {
        return false
    }

    return true
}

func installNpmPrompt(completionHandler: @escaping (Result<String, Error>) throws -> Void) throws {
    let alert = NSAlert()
    alert.messageText = "Couldn't seem to find \"npm\" installed on your system."
    alert.informativeText = "Would you like to let AuroraEditor install \"npm\" for you?"
    alert.addButton(withTitle: "Continue")
    alert.addButton(withTitle: "Cancel")
    if alert.runModal() == .alertFirstButtonReturn {
        let result = try ShellClient.live().run("brew install node")

        if !result.contains("Running `brew cleanup node`") {
            try completionHandler(.failure(ProjectValidationErrors.failureToInstallNPM("Failed to install npm")))
        }

        try completionHandler(.success("Successfully installed Npm"))
    }
}

func installBrewPrompt() throws {
    let alert = NSAlert()
    alert.messageText = "Couldn't seem to find \"brew\" installed on your system."
    alert.informativeText = "Please install brew before creating projects in AuroraEditor."
    alert.runModal()
}

func failureToInstall(installComponent: String) throws {
    let alert = NSAlert()
    alert.messageText = "AuroraEditor failed to install \"\(installComponent)\"."
    alert.informativeText = "Would you like to let AuroraEditor retry installing \"\(installComponent)\" for you?"
    alert.addButton(withTitle: "Retry")
    alert.addButton(withTitle: "Cancel")
    if alert.runModal() == .alertFirstButtonReturn {
        try ShellClient.live().run("brew install \(installComponent)")
    }
}

func failureToInstallNpmPackage(installComponent: String) throws {
    let alert = NSAlert()
    alert.messageText = "AuroraEditor failed to install \"\(installComponent)\"."
    alert.informativeText = "Would you like to let AuroraEditor retry installing \"\(installComponent)\" for you?"
    alert.addButton(withTitle: "Retry")
    alert.addButton(withTitle: "Cancel")
    if alert.runModal() == .alertFirstButtonReturn {
        try ShellClient.live().run("npm i \(installComponent)")
    }
}

enum ProjectValidationErrors: Error {
    case failureToInstallNPM(String)
}
