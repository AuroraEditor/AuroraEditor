//
//  WorkspaceDocument+CommandListeners.swift
//  AuroraEditor
//
//  Created by Khan Winter on 6/5/22.
//

import Foundation
import WorkspaceClient
import Combine

class WorkspaceNotificationModel: ObservableObject {
    init() {
        highlightedFileItem = nil
    }

    @Published var highlightedFileItem: WorkspaceClient.FileItem?
}
