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
                          langaugeIcon: "java"),
        FileSelectionItem(languageName: "C",
                          langaugeIcon: "c-programming"),
        FileSelectionItem(languageName: "C++",
                          langaugeIcon: "c-plus-plus"),
        FileSelectionItem(languageName: "C#",
                          langaugeIcon: "c-sharp-logo"),
        FileSelectionItem(languageName: "Kotlin",
                          langaugeIcon: "kotlin"),
        FileSelectionItem(languageName: "Swift",
                          langaugeIcon: "swift"),
        FileSelectionItem(languageName: "Dart",
                          langaugeIcon: "dart"),
        FileSelectionItem(languageName: "Typescript",
                          langaugeIcon: "typescript"),
        FileSelectionItem(languageName: "JavaScript",
                          langaugeIcon: "javascript"),
        FileSelectionItem(languageName: "HTML",
                          langaugeIcon: "html"),
        FileSelectionItem(languageName: "CSS",
                          langaugeIcon: "css3"),
        FileSelectionItem(languageName: "SASS",
                          langaugeIcon: "sass"),
        FileSelectionItem(languageName: "Ruby",
                          langaugeIcon: "ruby"),
        FileSelectionItem(languageName: "Go",
                          langaugeIcon: "golang"),
        FileSelectionItem(languageName: "Python",
                          langaugeIcon: "python"),
        FileSelectionItem(languageName: "Dockerfile",
                          langaugeIcon: "docker")
    ]

    @Published
    var projectItems = [
        FileSelectionItem(languageName: "Ionic",
                          langaugeIcon: "scale.3d"),
        FileSelectionItem(languageName: "React Native",
                          langaugeIcon: "scale.3d"),
        FileSelectionItem(languageName: "Flutter",
                          langaugeIcon: "scale.3d"),
        FileSelectionItem(languageName: "Xamarin",
                          langaugeIcon: "scale.3d"),
        FileSelectionItem(languageName: "Cordova",
                          langaugeIcon: "scale.3d"),
        FileSelectionItem(languageName: "Kotlin Multiplatform",
                          langaugeIcon: "scale.3d")
    ]

    @Published
    var crossPlatformProjects = [
        FileSelectionItem(languageName: "Flutter",
                          langaugeIcon: "fluttersvg"),
        FileSelectionItem(languageName: "Ionic",
                          langaugeIcon: "ionic"),
        FileSelectionItem(languageName: "Angular",
                          langaugeIcon: "angularjs"),
        FileSelectionItem(languageName: "React Native",
                          langaugeIcon: "react-native"),
        FileSelectionItem(languageName: "Kotlin Multiplatform",
                          langaugeIcon: "kotlin")
    ]

    @Published
    var aiMLProjects = [
        FileSelectionItem(languageName: "Python",
                          langaugeIcon: "python"),
        FileSelectionItem(languageName: "Java",
                          langaugeIcon: "java"),
        FileSelectionItem(languageName: "R",
                          langaugeIcon: "rlogo"),
        FileSelectionItem(languageName: "Haskell",
                          langaugeIcon: "haskell"),
        FileSelectionItem(languageName: "Julia",
                          langaugeIcon: "julia"),
        FileSelectionItem(languageName: "C++",
                          langaugeIcon: "c-plus-plus"),
        FileSelectionItem(languageName: "Lisp",
                          langaugeIcon: "lisp")
    ]

    @Published
    var webProjects = [
        FileSelectionItem(languageName: "Flutter",
                          langaugeIcon: "fluttersvg"),
        FileSelectionItem(languageName: "Ionic",
                          langaugeIcon: "ionic"),
        FileSelectionItem(languageName: "Angular",
                          langaugeIcon: "angularjs"),
        FileSelectionItem(languageName: "React JS",
                          langaugeIcon: "react-native"),
        FileSelectionItem(languageName: "Vue JS",
                          langaugeIcon: "vue-js"),
        FileSelectionItem(languageName: "Redux",
                          langaugeIcon: "redux"),
        FileSelectionItem(languageName: "Jenkins",
                          langaugeIcon: "jenkins"),
        FileSelectionItem(languageName: "Flask",
                          langaugeIcon: "flask"),
        FileSelectionItem(languageName: "Express JS",
                          langaugeIcon: "express-js"),
        FileSelectionItem(languageName: "Bootstrap",
                          langaugeIcon: "bootstrap")
    ]

    @Published
    var selectedSection: Int = 0
}
