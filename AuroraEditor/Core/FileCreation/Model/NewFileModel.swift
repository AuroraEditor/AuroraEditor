//
//  NewFileModel.swift
//  Aurora Editor
//
//  Created by TAY KAI QUAN on 8/9/22.
//  Copyright © 2023 Aurora Company. All rights reserved.
//

import Foundation
import SwiftUI

/// New File Model
class NewFileModel: ObservableObject {
    /// Workspace
    var workspace: WorkspaceDocument?

    /// Initialize New File Model
    /// 
    /// - Parameter workspace: workspace
    init(workspace: WorkspaceDocument? = nil) {
        self.workspace = workspace
    }

    /// Show file creation sheet
    @Published
    var showFileCreationSheet: Bool = false {
        didSet {
            // this is to let the WorkspaceView reload, because calling this class's
            // objectWillChange seems to do nothing.
            workspace?.objectWillChange.send()
        }
    }

    /// Source URL
    @Published
    var sourceURL: URL?

    /// Outline view selection
    @Published
    var outlineViewSelection: FileItem?

    /// Show sheet with URL
    /// 
    /// - Parameter url: URL
    func showSheetWithUrl(url: URL?) {
        showFileCreationSheet.toggle()
        sourceURL = url
    }
}
