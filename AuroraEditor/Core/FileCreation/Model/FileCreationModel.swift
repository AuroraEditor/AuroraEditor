//
//  FileCreationModel.swift
//  Aurora Editor
//
//  Created by Nanashi Li on 2022/09/01.
//  Copyright © 2023 Aurora Company. All rights reserved.
//

import AppKit

/// File creation model
@MainActor
class FileCreationModel: ObservableObject {
    /// Shared instance
    public static var shared: FileCreationModel = .init()

    /// File manager
    private let fileManager: FileManager = .default

    /// Language items
    @Published
    var languageItems = [
        FileSelectionItem(languageName: "Java",
                          langaugeIcon: "java",
                          languageExtension: "java"),
        FileSelectionItem(languageName: "C",
                          langaugeIcon: "c-programming",
                          languageExtension: "c"),
        FileSelectionItem(languageName: "C++",
                          langaugeIcon: "c-plus-plus",
                          languageExtension: "cpp"),
        FileSelectionItem(languageName: "C#",
                          langaugeIcon: "c-sharp-logo",
                          languageExtension: "cs"),
        FileSelectionItem(languageName: "Kotlin",
                          langaugeIcon: "kotlin",
                          languageExtension: "kt"),
        FileSelectionItem(languageName: "Swift",
                          langaugeIcon: "swift",
                          languageExtension: "swift"),
        FileSelectionItem(languageName: "Dart",
                          langaugeIcon: "dart",
                          languageExtension: "dart"),
        FileSelectionItem(languageName: "Typescript",
                          langaugeIcon: "typescript",
                          languageExtension: "ts"),
        FileSelectionItem(languageName: "JavaScript",
                          langaugeIcon: "javascript",
                          languageExtension: "js"),
        FileSelectionItem(languageName: "HTML",
                          langaugeIcon: "html",
                          languageExtension: "html"),
        FileSelectionItem(languageName: "CSS",
                          langaugeIcon: "css3",
                          languageExtension: "css"),
        FileSelectionItem(languageName: "SASS",
                          langaugeIcon: "sass",
                          languageExtension: "scss"),
        FileSelectionItem(languageName: "Ruby",
                          langaugeIcon: "ruby",
                          languageExtension: "rb"),
        FileSelectionItem(languageName: "Go",
                          langaugeIcon: "golang",
                          languageExtension: "go"),
        FileSelectionItem(languageName: "Python",
                          langaugeIcon: "python",
                          languageExtension: "py"),
        FileSelectionItem(languageName: "Dockerfile",
                          langaugeIcon: "docker",
                          languageExtension: "dockerfile")
    ]

    /// Selected language item
    @Published
    var selectedLanguageItem: FileSelectionItem = FileSelectionItem(languageName: "Java",
                                                                    langaugeIcon: "java",
                                                                    languageExtension: "java")

    /// Create a new file with the selected language
    /// 
    /// - Parameter workspace: Workspace document
    /// - Parameter fileName: File name
    /// - Parameter completionHandler: Completion handler
    func createLanguageFile(workspace: WorkspaceDocument,
                            fileName: String,
                            completionHandler: @escaping (Result<String, Error>) -> Void) {
        guard let directoryURL = workspace.newFileModel.sourceURL ??
                                 workspace.fileSystemClient?.folderURL else { return }
        let newFilePath = directoryURL.appendingPathComponent(fileName)
        if !fileManager.fileExists(atPath: newFilePath.path) {
            createFileWithStarterContent(atPath: newFilePath.path, fileName: fileName)
            completionHandler(.success("Success"))
        } else {
            let alert = NSAlert()
            alert.messageText = "\"\(fileName)\" already exists. Do you want to replace it?"
            alert.alertStyle = .critical
            // swiftlint:disable:next line_length
            alert.informativeText = "A file or folder with the same name already exists in the selected folder. Replacing it will overwrite its current contents."
            alert.addButton(withTitle: "Replace")
            alert.buttons.last?.hasDestructiveAction = true
            alert.addButton(withTitle: "Cancel")
            if alert.runModal() == .alertFirstButtonReturn {
                do {
                    try fileManager.removeItem(at: newFilePath)
                    createFileWithStarterContent(atPath: newFilePath.path, fileName: fileName)
                    completionHandler(.success("Success"))
                } catch {
                    completionHandler(
                        .failure(
                            FileCreationError.unableToReplace(
                                "Unable to replace file at path: \(newFilePath)."
                            )
                        )
                    )
                }
            }
        }
    }

    /// Create a new file with the selected language
    /// 
    /// - Parameter path: at path
    /// - Parameter fileName: file name
    private func createFileWithStarterContent(atPath path: String, fileName: String) {
        let name = Host.current().localizedName ?? "Aurora Editor"
        let fileContent = Data("""
//
//  \(fileName)
//
//  Created by \(name) on \(Date().yearMonthDayFormat()).
//
""".utf8)

        fileManager.createFile(
            atPath: path,
            contents: fileContent,
            attributes: [
                .ownerAccountName: name,
                .creationDate: Date()
            ]
        )
    }
}

/// File creation error
enum FileCreationError: Error {
    /// Unable to replace
    case unableToReplace(String)
}
