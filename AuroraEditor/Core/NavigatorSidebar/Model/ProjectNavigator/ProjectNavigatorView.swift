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
struct ProjectNavigatorView: NSViewControllerRepresentable, @preconcurrency Equatable {
    @EnvironmentObject var workspace: WorkspaceDocument
    @ObservedObject var prefs: AppPreferencesModel

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
        if nsViewController.iconColor != prefs.preferences.general.fileIconStyle {
            nsViewController.iconColor = prefs.preferences.general.fileIconStyle
        }
        if nsViewController.rowHeight != prefs.preferences.general.projectNavigatorSize.rowHeight {
            nsViewController.rowHeight = prefs.preferences.general.projectNavigatorSize.rowHeight
        }
        if nsViewController.fileExtensionsVisibility != prefs.preferences.general.fileExtensionsVisibility {
            nsViewController.fileExtensionsVisibility = prefs.preferences.general.fileExtensionsVisibility
        }
        if nsViewController.shownFileExtensions != prefs.preferences.general.shownFileExtensions {
            nsViewController.shownFileExtensions = prefs.preferences.general.shownFileExtensions
        }
        if nsViewController.hiddenFileExtensions != prefs.preferences.general.hiddenFileExtensions {
            nsViewController.hiddenFileExtensions = prefs.preferences.general.hiddenFileExtensions
        }
        nsViewController.updateSelection()
    }

    /// Make the coordinator
    func makeCoordinator() -> Coordinator {
        Coordinator(workspace)
    }

    static func == (lhs: ProjectNavigatorView, rhs: ProjectNavigatorView) -> Bool {
        lhs.prefs.preferences.general.fileIconStyle == rhs.prefs.preferences.general.fileIconStyle &&
        lhs.prefs.preferences.general.projectNavigatorSize.rowHeight == rhs.prefs.preferences.general.projectNavigatorSize.rowHeight && // swiftlint:disable:this line_length
        lhs.prefs.preferences.general.fileExtensionsVisibility == rhs.prefs.preferences.general.fileExtensionsVisibility && // swiftlint:disable:this line_length
        lhs.prefs.preferences.general.shownFileExtensions == rhs.prefs.preferences.general.shownFileExtensions &&
        lhs.prefs.preferences.general.hiddenFileExtensions == rhs.prefs.preferences.general.hiddenFileExtensions
    }

    class Coordinator: NSObject {
        /// Initialize the coordinator
        /// 
        /// - Parameter workspace: the workspace document
        /// 
        /// - Returns: the coordinator
        @MainActor
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
