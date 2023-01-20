//
//  FileCreationModel.swift
//  Aurora Editor
//
//  Created by Nanashi Li on 2022/09/01.
//

import AppKit

class FileCreationModel: ObservableObject {

    public static var shared: FileCreationModel = .init()

    private let fileManager: FileManager = .default

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

    @Published
    var selectedLanguageItem: FileSelectionItem = FileSelectionItem(languageName: "Java",
                                                                    langaugeIcon: "java",
                                                                    languageExtension: "java")

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
                    // swiftlint:disable:next line_length
                    completionHandler(.failure(FileCreationError.unableToReplace("Unable to replace file at path: \(newFilePath).")))
                }
            }
        }
    }

    private func createFileWithStarterContent(atPath path: String, fileName: String) {
        let fileContent = """
//
//  \(fileName)
//
//  Created by \(Host.current().localizedName!) on \(Date().yearMonthDayFormat()).
//
""".data(using: .utf8)

        fileManager.createFile(atPath: path,
                               contents: fileContent,
                               attributes: [.ownerAccountName: Host.current().localizedName!,
                                            .creationDate: Date()])
    }
}

enum FileCreationError: Error {
    case unableToReplace(String)
}
