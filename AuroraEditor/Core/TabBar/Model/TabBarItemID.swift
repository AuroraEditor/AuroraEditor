//
//  TabBarItemID.swift
//  Aurora Editor
//
//  Created by Pavel Kasila on 30.04.22.
//  Copyright © 2023 Aurora Company. All rights reserved.
//

import SwiftUI

/// Enum to represent item's ID to tab bar
public enum TabBarItemID: Codable, Identifiable, Hashable {
    /// Identifier of the item
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
        case .extensionCustomView(let extensionName):
            return "cus_ext_\(extensionName)"
        }
    }

    /// Represents file representation of the item
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
        case .extensionCustomView(let extensionName):
            return "auroraeditor//extension/\(extensionName)/view"
        }
    }

    /// File path
    public var filePath: String? {
        switch self {
        case .codeEditor(let path):
            return path
        default:
            return nil
        }
    }

    /// Represents code editor tab
    case codeEditor(String)

    /// Represents extension installation tab
    case extensionInstallation(String)

    /// Represents web tab
    case webTab(String)

    /// Represents project history tab
    case projectHistory(String)

    /// Represents branch history tab
    case branchHistory(String)

    /// Represents actions workflow tab
    case actionsWorkflow(String)

    /// Represents extension custom view tab
    case extensionCustomView(String)
}
