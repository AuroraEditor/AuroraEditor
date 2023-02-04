//
//  WorkspaceDocument+CommandListeners.swift
//  Aurora Editor
//
//  Created by Khan Winter on 6/5/22.
//  Copyright © 2023 Aurora Company. All rights reserved.
//

import Foundation
import Combine

class WorkspaceNotificationModel: ObservableObject {
    init() {
        highlightedFileItem = nil
    }

    @Published
    var highlightedFileItem: FileSystemClient.FileItem?
}
