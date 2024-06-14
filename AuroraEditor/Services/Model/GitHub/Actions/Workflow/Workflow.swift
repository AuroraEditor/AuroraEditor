//
//  Workflow.swift
//  Aurora Editor
//
//  Created by Nanashi Li on 2022/09/13.
//  Copyright © 2023 Aurora Company. All rights reserved.
//

import SwiftUI
import Version_Control

/// GitHub Actions Workflow
extension Workflow: TabBarItemRepresentable {
    /// Equatable
    /// 
    /// - Parameter lhs: left hand side
    /// - Parameter rhs: right hand side
    /// 
    /// - Returns: true if equal
    static func == (lhs: Workflow, rhs: Workflow) -> Bool {
        guard lhs.tabID == rhs.tabID else { return false }
        guard lhs.title == rhs.title else { return false }
        return true
    }

    /// Tab ID
    public var tabID: TabBarItemID {
        .actionsWorkflow(String(id))
    }

    /// Tab Title
    public var title: String {
        name
    }

    /// Tab Icon
    public var icon: Image {
        Image(systemName: "diamond")
    }

    /// Tab Icon Color
    public var iconColor: Color {
        return .secondary
    }
}
