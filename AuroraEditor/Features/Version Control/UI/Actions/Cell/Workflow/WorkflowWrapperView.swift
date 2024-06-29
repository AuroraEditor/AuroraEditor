//
//  WorkflowWrapperView.swift
//  Aurora Editor
//
//  Created by Nanashi Li on 2022/09/18.
//  Copyright © 2023 Aurora Company. All rights reserved.
//

import SwiftUI
import Combine

/// Wraps a ``WorkflowWrapperView`` inside a `NSViewControllerRepresentable`
struct WorkflowWrapperView: NSViewControllerRepresentable {

    @EnvironmentObject
    var workspace: WorkspaceDocument

    @State
    var actionsModel: GitHubActions

    @StateObject
    var prefs: AppPreferencesModel = .shared

    typealias NSViewControllerType = WorkflowViewController

    func makeNSViewController(context: Context) -> WorkflowViewController {
        let controller = WorkflowViewController()
        controller.workspace = workspace
        controller.actionsModel = actionsModel

        context.coordinator.controller = controller

        return controller
    }

    func updateNSViewController(_ nsViewController: WorkflowViewController, context: Context) {
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

        var listener: AnyCancellable?
        var workspace: WorkspaceDocument
        var controller: WorkflowViewController?

        deinit {
            listener?.cancel()
        }
    }
}
