//
//  Workflow.swift
//  AuroraEditor
//
//  Created by Nanashi Li on 2022/09/13.
//  Copyright © 2022 Aurora Company. All rights reserved.
//

import Foundation
import SwiftUI

struct Workflow: Codable, Hashable, Identifiable, TabBarItemRepresentable {

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

    let id: Int
    let node_id: String
    let name: String
    let path: String
    let state: String
    let created_at: String
    let updated_at: String
    let url: String
    let html_url: String
}
