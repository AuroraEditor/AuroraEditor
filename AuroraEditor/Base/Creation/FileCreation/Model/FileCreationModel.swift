//
//  FileCreationModel.swift
//  AuroraEditor
//
//  Created by Nanashi Li on 2022/09/01.
//  Copyright © 2022 Aurora Company. All rights reserved.
//

import Foundation

class FileCreationModel: ObservableObject {

    public static var shared: FileCreationModel = .init()

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
                          languageExtension: ".dockerfile")
    ]

    @Published
    var selectedLanguageItem: FileSelectionItem = FileSelectionItem(languageName: "Java",
                                                                    langaugeIcon: "java",
                                                                    languageExtension: "java")
}
