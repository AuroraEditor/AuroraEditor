//
//  WorkspaceDocument+CommandListeners.swift
//  Aurora Editor
//
//  Created by Khan Winter on 6/5/22.
//  Copyright © 2023 Aurora Company. All rights reserved.
//

import Foundation
import Combine

/// A class that represents the workspace document command listeners.
@MainActor
class WorkspaceNotificationModel: ObservableObject {
    /// The highlighted file item
    init() {
        highlightedFileItem = nil
    }

    /// The highlighted file item
    @Published
    var highlightedFileItem: FileSystemClient.FileItem?
}
