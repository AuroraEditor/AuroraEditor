//
//  SourceControlView.swift
//  AuroraEditor
//
//  Created by Nanashi Li on 2022/08/10.
//  Copyright © 2022 Aurora Company. All rights reserved.
//

import SwiftUI
import Combine

struct SourceControlView: NSViewControllerRepresentable {

    @EnvironmentObject
    var workspace: WorkspaceDocument

    @StateObject
    var prefs: AppPreferencesModel = .shared

    typealias NSViewControllerType = SourceControlController

    func makeNSViewController(context: Context) -> SourceControlController {
        let controller = SourceControlController()
        controller.workspace = workspace
        controller.iconColor = prefs.preferences.general.fileIconStyle

        context.coordinator.controller = controller

        return controller
    }

    func updateNSViewController(_ nsViewController: SourceControlController, context: Context) {
        nsViewController.iconColor = prefs.preferences.general.fileIconStyle
        nsViewController.rowHeight = prefs.preferences.general.projectNavigatorSize.rowHeight
        nsViewController.fileExtensionVisibility = prefs.preferences.general.fileExtensionsVisibility
        nsViewController.shownFileExtensions = prefs.preferences.general.shownFileExtensions
        nsViewController.hiddenFileExtensions = prefs.preferences.general.hiddenFileExtensions
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
        var controller: SourceControlController?

        deinit {
            listener?.cancel()
        }
    }
}
