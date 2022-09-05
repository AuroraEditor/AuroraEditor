//
//  ProjectCreationModel.swift
//  AuroraEditor
//
//  Created by Nanashi Li on 2022/09/02.
//  Copyright © 2022 Aurora Company. All rights reserved.
//

import AppKit

class ProjectCreationModel: ObservableObject {

    public static var shared: ProjectCreationModel = .init()

    private let fileManager: FileManager = .default

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

    func createAEProject(projectName: String,
                         completionHandler: @escaping (Result<String, Error>) -> Void) {
        if !doesAEDirecotryExist() {
            createAEDirectory()
        }

//        if !doesProjectDirectoryExists(projectName: projectName) {
//            createProjectDirectory(projectName: projectName)
//        } else {
//            return
//        }

        do {
            if selectedProjectItem.languageName == "React Native" {
                try createReactNativeProject(auroraDirectory: aeURLPath(),
                                             projectName: projectName)
                completionHandler(.success("React Native project created successfully"))
            } else if selectedProjectItem.languageName == "React JS" {
                try createReactWebProject(auroraDirectory: aeURLPath(),
                                          projectName: projectName, completionHandler: { completion in
                    switch completion {
                    case .success:
                        completionHandler(.success("React project created successfully"))
                    case .failure(let error):
                        completionHandler(.failure(error))
                    }
                })
            }
        } catch {
            completionHandler(.failure(ProjectCreationError.failedToCreateProject))
        }
    }

    func aeURLPath() -> URL {
        guard let aeProjectPath = fileManager.urls(for: .documentDirectory,
                                                  in: .userDomainMask).first else {
            return URL(string: "")!
        }

        return aeProjectPath.appendingPathComponent("AuroraEditor")
    }

    func doesAEDirecotryExist() -> Bool {
        return fileManager.directoryExistsAtPath(aeURLPath().path)
    }

    func createAEDirectory() {
        do {
            try fileManager.createDirectory(at: aeURLPath(),
                                            withIntermediateDirectories: true,
                                            attributes: [:])
        } catch {
            Log.error("Failed to create Aurora Editor directory")
        }
    }

    func projectURLPath(projectName: String) -> URL {
        return aeURLPath().appendingPathComponent(projectName)
    }

    func doesProjectDirectoryExists(projectName: String) -> Bool {
        return fileManager.directoryExistsAtPath(projectURLPath(projectName: projectName).path)
    }

    func createProjectDirectory(projectName: String) {
        do {
            try fileManager.createDirectory(at: projectURLPath(projectName: projectName),
                                            withIntermediateDirectories: true,
                                            attributes: [:])
        } catch {
            let alert = NSAlert()
            alert.messageText = "Failed to create directory at \"\(projectURLPath(projectName: projectName))\""
            alert.informativeText = "Consider naming your project to something else."
            alert.alertStyle = .critical
            alert.runModal()
        }
    }
}

enum ProjectCreationError: String, Error {
    case failedToCreateProject = "Failed to create project"
}
