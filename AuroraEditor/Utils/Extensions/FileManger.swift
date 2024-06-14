//
//  FileManger.swift
//  Aurora Editor
//
//  Created by Nanashi Li on 2022/08/16.
//  Copyright © 2023 Aurora Company. All rights reserved.
//

import Foundation

extension FileManager {
    /// Check if directory exists at path
    /// 
    /// - Parameter path: path
    /// 
    /// - Returns: true if directory exists
    func directoryExistsAtPath(_ path: String) -> Bool {
        var isDirectory: ObjCBool = true
        let exists = self.fileExists(atPath: "file://\(path)", isDirectory: &isDirectory)
        return exists && isDirectory.boolValue
    }
}
