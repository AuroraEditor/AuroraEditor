//
//  AuroraProject.swift
//  Aurora Editor
//
//  Created by Wesley de Groot on 05/07/2022.
//  Copyright © 2023 Aurora Company. All rights reserved.
//

import Foundation

/// AuroraProjectFile
struct AuroraProjectFile: Codable {
    /// Filename
    var file: String

    /// Time
    var time: Int
}

/// AuroraProject
struct AuroraProject: Codable {
    /// Aurora Project name
    var auroraProject: String?

    /// Files
    var files: [String]?

    /// Last search
    var lastSearch: String?

    /// Last replace
    var lastReplace: String?

    /// Last open file
    var lastOpenFile: String?

    /// State
    var state: String?

    /// Total time spend on this project
    var totalTimeSpend: Int?

    /// Time spend on files
    var timeOn: [AuroraProjectFile]?
}

/*
 {
     "auroraProject": "1.0",
     "files": [
         "a.ext",
         "b.ext",
         "c.ext"
     ],
     "lastSearch": null,
     "lastReplace": null,
     "lastOpenFile": null,
     "state": null,
     "totalTimeSpend": 60,
     "timeOn": [
         {"file": "a.ext","time": 10},
         {"file": "b.ext","time": 20},
         {"file": "c.ext","time": 30},
     ]
 }
 */
