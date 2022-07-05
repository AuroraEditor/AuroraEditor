//
//  AuroraProject.swift
//  CodeEdit
//
//  Created by Wesley de Groot on 05/07/2022.
//

import Foundation

struct AuroraProjectFile: Codable {
    var file: String
    var time: Int
}

/// <#Description#>
struct AuroraProject: Codable {
    var auroraProject: String?
    var files: [String]?
    var lastSearch: String?
    var lastReplace: String?
    var lastOpenFile: String?
    var state: String? // State.

    /* Nerd stats */
    var totalTimeSpend: Int?
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
