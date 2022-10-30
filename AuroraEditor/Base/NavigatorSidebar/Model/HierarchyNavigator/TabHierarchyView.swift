//
//  TabHierarchyView.swift
//  AuroraEditor
//
//  Created by TAY KAI QUAN on 11/9/22.
//  Copyright © 2022 Aurora Company. All rights reserved.
//

import SwiftUI

/// Wraps a ``TabHierarchyViewController`` in a `NSViewControllerRepresentable`
struct TabHierarchyView: NSViewControllerRepresentable {

    @ObservedObject
    var workspace: WorkspaceDocument

    @StateObject
    var prefs: AppPreferencesModel = .shared

    typealias NSViewControllerType = TabHierarchyViewController

    func makeNSViewController(context: Context) -> TabHierarchyViewController {
        let controller = TabHierarchyViewController()
        controller.workspace = workspace

        context.coordinator.controller = controller

        return controller
    }

    func updateNSViewController(_ nsViewController: TabHierarchyViewController, context: Context) {
        nsViewController.rowHeight = prefs.preferences.general.projectNavigatorSize.rowHeight
        return
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(workspace)
    }

    class Coordinator: NSObject {
        init(_ workspace: WorkspaceDocument) {
            self.workspace = workspace
            super.init()
        }

        var workspace: WorkspaceDocument
        var controller: TabHierarchyViewController?
    }
}
