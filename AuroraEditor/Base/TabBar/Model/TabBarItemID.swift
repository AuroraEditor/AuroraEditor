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
            return "extensionInstallation_\(id)"
        case .webTab(let url):
            return "webTab_\(url)"
        case .projectHistory(let project):
            return project
        case .branchHistory(let branch):
            return branch
        case .actionsWorkflow(let workflow):
            return workflow
        }
    }

    public var fileRepresentation: String {
        switch self {
        case .codeEditor(let path):
            return path
        case .extensionInstallation(let id):
            return "auroraeditor://extension/\(id)"
        case .webTab(let url):
            return url
        case .projectHistory(let project):
            return "auroraeditor://project/\(project)"
        case .branchHistory(let branch):
            return "auroraeditor://branch/\(branch)"
        case .actionsWorkflow(let workflow):
            return "auroraeditor://workflow/\(workflow)"
        }
    }

    /// Represents code editor tab
    case codeEditor(String)

    /// Represents extension installation tab
    case extensionInstallation(String)

    /// Represents web tab
    case webTab(String)

    case projectHistory(String)

    case branchHistory(String)

    case actionsWorkflow(String)
}
