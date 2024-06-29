//
//  ProjectNavigatorOutlineView.swift
//  Aurora Editor
//
//  Created by TAY KAI QUAN on 14/8/22.
//  Copyright © 2023 Aurora Company. All rights reserved.
//

import SwiftUI
import Combine

/// Wraps an ``ProjectNavigatorViewController`` inside a `NSViewControllerRepresentable`
struct ProjectNavigatorView: NSViewControllerRepresentable {
    /// The workspace document
    @EnvironmentObject
    var workspace: WorkspaceDocument

    /// App preferences model
    @StateObject
    var prefs: AppPreferencesModel = .shared

    typealias NSViewControllerType = ProjectNavigatorViewController

    /// Make the view controller
    /// 
    /// - Parameter context: the context
    /// 
    /// - Returns: the view controller
    func makeNSViewController(context: Context) -> ProjectNavigatorViewController {
        let controller = ProjectNavigatorViewController()
        controller.workspace = workspace
        workspace.fileSystemClient?.onRefresh = {
            controller.reloadData()
        }
        controller.iconColor = prefs.preferences.general.fileIconStyle

        context.coordinator.controller = controller

        return controller
    }

    /// Update the view controller
    /// 
    /// - Parameter nsViewController: the view controller
    /// - Parameter context: the context
    func updateNSViewController(_ nsViewController: ProjectNavigatorViewController, context: Context) {
        nsViewController.iconColor = prefs.preferences.general.fileIconStyle
        nsViewController.rowHeight = prefs.preferences.general.projectNavigatorSize.rowHeight
        nsViewController.fileExtensionsVisibility = prefs.preferences.general.fileExtensionsVisibility
        nsViewController.shownFileExtensions = prefs.preferences.general.shownFileExtensions
        nsViewController.hiddenFileExtensions = prefs.preferences.general.hiddenFileExtensions
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
        /// 
        /// - Returns: the coordinator
        init(_ workspace: WorkspaceDocument) {
            self.workspace = workspace
            super.init()

            listener = workspace.listenerModel.$highlightedFileItem
                .sink(receiveValue: { [weak self] fileItem in
                guard let fileItem = fileItem else {
                    return
                }
                self?.controller?.reveal(fileItem)
            })
        }

        /// The listener
        var listener: AnyCancellable?

        /// The workspace document
        var workspace: WorkspaceDocument

        /// The view controller
        var controller: ProjectNavigatorViewController?

        /// Deinirializer
        deinit {
            listener?.cancel()
        }
    }
}
