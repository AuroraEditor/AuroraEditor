//
//  Stage.swift
//  Aurora Editor
//
//  Created by Nanashi Li on 2022/08/13.
//  This source code is restricted for Aurora Editor usage only.
//

import Foundation

/// Stages a file with the given manual resolution method.
/// Useful for resolving binary conflicts at commit-time.
func stageManualConflictResolution(directoryURL: URL,
                                   file: FileItem,
                                   manualResoultion: ManualConflictResolution) throws {
    let status = file

    // TODO: Check conflicted state and conflicted with markers
}
