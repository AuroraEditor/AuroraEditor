//
//  SourceControlView.swift
//  Aurora Editor
//
//  Created by Nanashi Li on 2022/08/10.
//  Copyright © 2023 Aurora Company. All rights reserved.
//

import SwiftUI
import Combine

/// A `NSViewController` that displays the source control changes in the workspace.
struct SourceControlView: NSViewControllerRepresentable {

    /// The workspace document.
    @EnvironmentObject
    var workspace: WorkspaceDocument

    /// Application preferences model
    @StateObject
    var prefs: AppPreferencesModel = .shared

    typealias NSViewControllerType = SourceControlController

    /// Make the view controller.
    /// 
    /// - Parameter context: the context
    /// 
    /// - Returns: the view controller
    func makeNSViewController(context: Context) -> SourceControlController {
        let controller = SourceControlController()
        controller.workspace = workspace
        controller.iconColor = prefs.preferences.general.fileIconStyle

        context.coordinator.controller = controller

        return controller
    }

    /// Update the view controller.
    /// 
    /// - Parameter nsViewController: the view controller
    /// - Parameter context: the context
    func updateNSViewController(_ nsViewController: SourceControlController, context: Context) {
        nsViewController.iconColor = prefs.preferences.general.fileIconStyle
        nsViewController.rowHeight = prefs.preferences.general.projectNavigatorSize.rowHeight
        nsViewController.fileExtensionVisibility = prefs.preferences.general.fileExtensionsVisibility
        nsViewController.shownFileExtensions = prefs.preferences.general.shownFileExtensions
        nsViewController.hiddenFileExtensions = prefs.preferences.general.hiddenFileExtensions
        return
    }

    /// Make the coordinator.
    func makeCoordinator() -> Coordinator {
        Coordinator(workspace)
    }

    /// Coordinator for the view.
    class Coordinator: NSObject {
        /// Initialize the coordinator.
        /// 
        /// - Parameter workspace: the workspace document
        /// 
        /// - Returns: the coordinator
        init(_ workspace: WorkspaceDocument) {
            self.workspace = workspace
            super.init()
        }

        /// Listener for the workspace.
        var listener: AnyCancellable?

        /// The workspace document.
        var workspace: WorkspaceDocument

        /// The controller.
        var controller: SourceControlController?

        /// Deinitialize the coordinator.
        deinit {
            listener?.cancel()
        }
    }
}
