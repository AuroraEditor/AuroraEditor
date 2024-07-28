//
//  NotificationKeys.swift
//  Aurora Editor
//
//  Created by Wesley de Groot on 20/02/2024.
//  Copyright © 2024 Aurora Company. All rights reserved.
//

import Foundation

extension Notification.Name {
    /// Open in terminal
    static let openInTerminal = Notification.Name("AE.openInTerminal")

    /// Did begin editing
    static let didBeginEditing = Notification.Name("AE.didBeginEditing")

    /// Did change navigator pane selection
    static let changeNavigatorPane = Notification.Name("AE.changeNavigatorPane")

    /// Did change caret position
    static let didChangeCaretPosition = Notification.Name("AE.didChangeCaretPosition")

    /// The current branch has been updated
    static let gitBranchUpdated = Notification.Name("AE.gitBranchUpdated")
}
