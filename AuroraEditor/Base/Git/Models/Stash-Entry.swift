//
//  Stash-Entry.swift
//  Aurora Editor
//
//  Created by Nanashi Li on 2022/08/15.
//  Copyright © 2023 Aurora Company. All rights reserved.
//
//  This source code is restricted for Aurora Editor usage only.
//

import Foundation

protocol IStashEntry {
    /// The fully qualified name of the entry i.e., `refs/stash@{0}`
    var name: String? { get }
    /// The name of the branch at the time the entry was created.
    var branchName: String? { get }
    /// The SHA of the commit object created as a result of stashing.
    var stashSha: String? { get }
    /// The list of files this stash touches
    var files: FileItem? { get }
}

class StashEntry: IStashEntry {
    var name: String?
    var branchName: String?
    var stashSha: String?
    var files: FileItem?

    init(name: String?,
         branchName: String?,
         stashSha: String?,
         files: FileItem?) {
        self.branchName = branchName
        self.name = name
        self.stashSha = stashSha
        self.files = files
    }
}

/// Whether file changes for a stash entry are loaded or not
enum StashedChangesLoadStates: String {
    case notLoaded = "NotLoaded"
    case loading = "Loading"
    case loaded = "Loaded"
}
