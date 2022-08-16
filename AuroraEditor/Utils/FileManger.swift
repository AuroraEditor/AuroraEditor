//
//  FileManger.swift
//  AuroraEditor
//
//  Created by Nanashi Li on 2022/08/16.
//  Copyright © 2022 Aurora Company. All rights reserved.
//

import Foundation

extension FileManager {
    func directoryExistsAtPath(_ path: String) -> Bool {
        var isDirectory: ObjCBool = true
        let exists = self.fileExists(atPath: "file://\(path)", isDirectory: &isDirectory)
        return exists && isDirectory.boolValue
    }
}
