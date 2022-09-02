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
                          langaugeIcon: "scale.3d"),
        FileSelectionItem(languageName: "C++",
                          langaugeIcon: "scale.3d"),
        FileSelectionItem(languageName: "Kotlin",
                          langaugeIcon: "scale.3d"),
        FileSelectionItem(languageName: "Carbon",
                          langaugeIcon: "scale.3d"),
        FileSelectionItem(languageName: "C#",
                          langaugeIcon: "scale.3d"),
        FileSelectionItem(languageName: "Swift",
                          langaugeIcon: "scale.3d"),
        FileSelectionItem(languageName: "Rust",
                          langaugeIcon: "scale.3d")
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
    var selectedSection: Int = 0
}
