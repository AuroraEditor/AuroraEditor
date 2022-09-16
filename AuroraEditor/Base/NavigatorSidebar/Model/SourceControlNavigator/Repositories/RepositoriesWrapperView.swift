//
//  RepositoriesWrapperView.swift
//  AuroraEditor
//
//  Created by TAY KAI QUAN on 17/8/22.
//  Copyright © 2022 Aurora Company. All rights reserved.
//

import SwiftUI
import Combine

/// Wraps a ``RepositoriesViewController`` inside a `NSViewControllerRepresentable`
struct RepositoriesWrapperView: NSViewControllerRepresentable {

    @StateObject
    var workspace: WorkspaceDocument

    @State
    var repository: RepositoryModel

    @StateObject
    var prefs: AppPreferencesModel = .shared

    typealias NSViewControllerType = RepositoriesViewController

    func makeNSViewController(context: Context) -> RepositoriesViewController {
        let controller = RepositoriesViewController()
        controller.workspace = workspace
        controller.repository = repository

        context.coordinator.controller = controller

        return controller
    }

    func updateNSViewController(_ nsViewController: RepositoriesViewController, context: Context) {
        nsViewController.rowHeight = prefs.preferences.general.projectNavigatorSize.rowHeight
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
        }

        var listener: AnyCancellable?
        var workspace: WorkspaceDocument
        var controller: RepositoriesViewController?

        deinit {
            listener?.cancel()
        }
    }
}
