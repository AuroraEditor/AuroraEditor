//
//  WorkspaceExtension.swift
//  Aurora Editor
//
//  Created by Nanashi Li on 2022/09/06.
//  Copyright © 2023 Aurora Company. All rights reserved.
//

import Foundation

extension WorkspaceDocument {

    func workspaceURL() -> URL {
        guard let workspaceFolder = self.fileSystemClient?.folderURL else {
            fatalError("Unconstructable URL")
        }
        return workspaceFolder
    }
}
