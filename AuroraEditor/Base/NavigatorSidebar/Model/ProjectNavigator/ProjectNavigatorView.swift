//
//  ProjectNavigatorOutlineView.swift
//  AuroraEditor
//
//  Created by TAY KAI QUAN on 14/8/22
//

import SwiftUI
import Combine

/// Wraps an ``ProjectNavigatorViewController`` inside a `NSViewControllerRepresentable`
struct ProjectNavigatorView: NSViewControllerRepresentable {

    @StateObject
    var workspace: WorkspaceDocument

    @StateObject
    var prefs: AppPreferencesModel = .shared

    typealias NSViewControllerType = ProjectNavigatorViewController

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

    func updateNSViewController(_ nsViewController: ProjectNavigatorViewController, context: Context) {
        nsViewController.iconColor = prefs.preferences.general.fileIconStyle
        nsViewController.rowHeight = prefs.preferences.general.projectNavigatorSize.rowHeight
        nsViewController.fileExtensionsVisibility = prefs.preferences.general.fileExtensionsVisibility
        nsViewController.shownFileExtensions = prefs.preferences.general.shownFileExtensions
        nsViewController.hiddenFileExtensions = prefs.preferences.general.hiddenFileExtensions
        nsViewController.updateSelection()
        return
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(workspace)
    }

    class Coordinator: NSObject {
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

        var listener: AnyCancellable?
        var workspace: WorkspaceDocument
        var controller: ProjectNavigatorViewController?

        deinit {
            listener?.cancel()
        }
    }
}
