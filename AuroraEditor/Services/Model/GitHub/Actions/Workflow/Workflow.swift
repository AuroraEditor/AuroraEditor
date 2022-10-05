//
//  Workflow.swift
//  AuroraEditor
//
//  Created by Nanashi Li on 2022/09/13.
//  Copyright © 2022 Aurora Company. All rights reserved.
//

import SwiftUI
import Version_Control

extension Workflow: TabBarItemRepresentable {
    static func == (lhs: Workflow, rhs: Workflow) -> Bool {
        guard lhs.tabID == rhs.tabID else { return false }
        guard lhs.title == rhs.title else { return false }
        return true
    }

    public var tabID: TabBarItemID {
        .actionsWorkflow(String(id))
    }

    public var title: String {
        name
    }

    public var icon: Image {
        Image(systemName: "diamond")
    }

    public var iconColor: Color {
        return .secondary
    }
}
