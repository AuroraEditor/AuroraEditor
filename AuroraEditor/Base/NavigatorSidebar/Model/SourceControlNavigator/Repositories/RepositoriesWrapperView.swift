//
//  RepositoriesWrapperView.swift
//  Aurora Editor
//
//  Created by TAY KAI QUAN on 17/8/22.
//  Copyright © 2023 Aurora Company. All rights reserved.
//

import SwiftUI
import Combine

/// Wraps a ``RepositoriesViewController`` inside a `NSViewControllerRepresentable`
struct RepositoriesWrapperView: NSViewControllerRepresentable {
    /// Workspace document
    @EnvironmentObject
    var workspace: WorkspaceDocument

    /// Repository model
    @State
    var repository: RepositoryModel

    /// Application preferences model
    @StateObject
    var prefs: AppPreferencesModel = .shared

    typealias NSViewControllerType = RepositoriesViewController

    /// Make the view controller
    /// 
    /// - Parameter context: the context
    /// 
    /// - Returns: the view controller
    func makeNSViewController(context: Context) -> RepositoriesViewController {
        let controller = RepositoriesViewController()
        controller.workspace = workspace
        controller.repository = repository

        context.coordinator.controller = controller

        return controller
    }

    /// Update the view controller
    /// 
    /// - Parameter nsViewController: the view controller
    /// - Parameter context: the context
    func updateNSViewController(_ nsViewController: RepositoriesViewController, context: Context) {
        nsViewController.rowHeight = prefs.preferences.general.projectNavigatorSize.rowHeight
        nsViewController.updateSelection()
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
        init(_ workspace: WorkspaceDocument) {
            self.workspace = workspace
            super.init()
        }

        /// Listener for the workspace
        var listener: AnyCancellable?

        /// Workspace document
        var workspace: WorkspaceDocument

        /// The view controller
        var controller: RepositoriesViewController?

        /// Deinitializer
        deinit {
            listener?.cancel()
        }
    }
}
