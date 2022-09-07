//
//  WorkspaceExtension.swift
//  AuroraEditor
//
//  Created by Nanashi Li on 2022/09/06.
//  Copyright © 2022 Aurora Company. All rights reserved.
//

import Foundation

extension WorkspaceDocument {

    func workspaceURL() -> URL {
        do {
            guard let workspaceFolder = self.fileSystemClient?.folderURL else {
                throw URLError(.fileDoesNotExist)
            }
            return workspaceFolder
        } catch {
            Log.error("Unable to get workspace url")
        }
        return URL(string: "")!
    }
}
