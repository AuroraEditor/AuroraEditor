//
//  TabHierarchyView.swift
//  Aurora Editor
//
//  Created by TAY KAI QUAN on 11/9/22.
//  Copyright © 2023 Aurora Company. All rights reserved.
//

import SwiftUI

/// Wraps a ``TabHierarchyViewController`` in a `NSViewControllerRepresentable`
struct TabHierarchyView: NSViewControllerRepresentable {

    /// The workspace document
    @EnvironmentObject
    var workspace: WorkspaceDocument

    /// App preferences model
    @StateObject
    var prefs: AppPreferencesModel = .shared

    typealias NSViewControllerType = TabHierarchyViewController

    /// Make the view controller
    /// 
    /// - Parameter context: the context
    /// 
    /// - Returns: the view controller
    func makeNSViewController(context: Context) -> TabHierarchyViewController {
        let controller = TabHierarchyViewController()
        controller.workspace = workspace

        context.coordinator.controller = controller

        return controller
    }

    /// Update the view controller
    /// 
    /// - Parameter nsViewController: the view controller
    /// - Parameter context: the context
    func updateNSViewController(_ nsViewController: TabHierarchyViewController, context: Context) {
        nsViewController.rowHeight = prefs.preferences.general.projectNavigatorSize.rowHeight
        return
    }

    /// Make the coordinator
    func makeCoordinator() -> Coordinator {
        Coordinator(workspace)
    }

    /// Coordinator for the view
    class Coordinator: NSObject {
        /// Initialize the coordinator
        /// 
        /// - Parameter workspace: the workspace document
        /// 
        /// - Returns: the coordinator
        init(_ workspace: WorkspaceDocument) {
            self.workspace = workspace
            super.init()
        }

        /// The workspace document
        var workspace: WorkspaceDocument

        /// The view controller
        var controller: TabHierarchyViewController?
    }
}
