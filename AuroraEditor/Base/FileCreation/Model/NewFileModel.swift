//
//  NewFileModel.swift
//  Aurora Editor
//
//  Created by TAY KAI QUAN on 8/9/22.
//  Copyright © 2023 Aurora Company. All rights reserved.
//

import Foundation
import SwiftUI

class NewFileModel: ObservableObject {
    var workspace: WorkspaceDocument?

    init(workspace: WorkspaceDocument? = nil) {
        self.workspace = workspace
    }

    @Published
    var showFileCreationSheet: Bool = false {
        didSet {
            // this is to let the WorkspaceView reload, because calling this class's
            // objectWillChange seems to do nothing.
            workspace?.objectWillChange.send()
        }
    }

    @Published
    var sourceURL: URL?

    @Published
    var outlineViewSelection: FileItem?

    func showSheetWithUrl(url: URL?) {
        showFileCreationSheet.toggle()
        sourceURL = url
    }
}
