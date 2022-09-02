//
//  ProjectCreationModel.swift
//  AuroraEditor
//
//  Created by Nanashi Li on 2022/09/02.
//  Copyright © 2022 Aurora Company. All rights reserved.
//

import Foundation

class ProjectCreationModel: ObservableObject {

    public static var shared: ProjectCreationModel = .init()

    @Published
    var crossPlatformProjects = [
        ProjectSelectionItem(languageName: "Flutter",
                             langaugeIcon: "fluttersvg"),
        ProjectSelectionItem(languageName: "Ionic",
                             langaugeIcon: "ionic"),
        ProjectSelectionItem(languageName: "Angular",
                             langaugeIcon: "angularjs"),
        ProjectSelectionItem(languageName: "React Native",
                             langaugeIcon: "react-native"),
        ProjectSelectionItem(languageName: "Kotlin Multiplatform",
                             langaugeIcon: "kotlin")
    ]

    @Published
    var aiMLProjects = [
        ProjectSelectionItem(languageName: "Python",
                             langaugeIcon: "python"),
        ProjectSelectionItem(languageName: "Java",
                             langaugeIcon: "java"),
        ProjectSelectionItem(languageName: "R",
                             langaugeIcon: "rlogo"),
        ProjectSelectionItem(languageName: "Haskell",
                             langaugeIcon: "haskell"),
        ProjectSelectionItem(languageName: "Julia",
                             langaugeIcon: "julia"),
        ProjectSelectionItem(languageName: "C++",
                             langaugeIcon: "c-plus-plus"),
        ProjectSelectionItem(languageName: "Lisp",
                             langaugeIcon: "lisp")
    ]

    @Published
    var webProjects = [
        ProjectSelectionItem(languageName: "Flutter",
                             langaugeIcon: "fluttersvg"),
        ProjectSelectionItem(languageName: "Ionic",
                             langaugeIcon: "ionic"),
        ProjectSelectionItem(languageName: "Angular",
                             langaugeIcon: "angularjs"),
        ProjectSelectionItem(languageName: "React JS",
                             langaugeIcon: "react-native"),
        ProjectSelectionItem(languageName: "Vue JS",
                             langaugeIcon: "vue-js"),
        ProjectSelectionItem(languageName: "Redux",
                             langaugeIcon: "redux"),
        ProjectSelectionItem(languageName: "Jenkins",
                             langaugeIcon: "jenkins"),
        ProjectSelectionItem(languageName: "Flask",
                             langaugeIcon: "flask"),
        ProjectSelectionItem(languageName: "Express JS",
                             langaugeIcon: "express-js"),
        ProjectSelectionItem(languageName: "Bootstrap",
                             langaugeIcon: "bootstrap")
    ]

    @Published
    var selectedSection: Int = 0

    @Published
    var selectedProjectItem: ProjectSelectionItem = ProjectSelectionItem(languageName: "Flutter",
                                                                         langaugeIcon: "fluttersvg")
}
