//
//  EditorSheetViewsModel.swift
//  AuroraEditor
//
//  Created by Nanashi Li on 2022/08/30.
//  Copyright © 2022 Aurora Company. All rights reserved.
//

import Foundation

/// By having and observable class handle the booleans we can show sheets from the WorkspaceView
class EditorSheetViewsModel: ObservableObject {
    public static let shared: EditorSheetViewsModel = .init()

    @Published
    var showFileCreationSheet: Bool = false

    @Published
    var isProjectCreation: Bool = false
}
