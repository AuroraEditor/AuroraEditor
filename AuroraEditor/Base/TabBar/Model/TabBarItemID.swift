//
//  TabBarItemID.swift
//  
//
//  Created by Pavel Kasila on 30.04.22.
//

import SwiftUI

/// Enum to represent item's ID to tab bar
public enum TabBarItemID: Codable, Identifiable, Hashable {
    public var id: String {
        switch self {
        case .codeEditor(let path):
            return "codeEditor_\(path)"
        case .extensionInstallation(let id):
            return "extensionInstallation_\(id.uuidString)"
        case .webTab(let url):
            // note: does not allow for multiple tabs of the same URL
            return "webTab_\(url)"
        case .projectHistory(let project):
            return project
        case .branchHistory(let branch):
            return branch
        }
    }

    /// Represents code editor tab
    case codeEditor(String)

    /// Represents extension installation tab
    case extensionInstallation(UUID)

    /// Represents web tab
    case webTab(String)

    case projectHistory(String)

    case branchHistory(String)
}
