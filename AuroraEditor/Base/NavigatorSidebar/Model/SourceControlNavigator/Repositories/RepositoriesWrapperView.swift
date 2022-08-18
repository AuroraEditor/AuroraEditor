//
//  RepositoriesView.swift
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
    var repository: DummyRepo

    @StateObject
    var prefs: AppPreferencesModel = .shared

    typealias NSViewControllerType = RepositoriesViewController

    func makeNSViewController(context: Context) -> RepositoriesViewController {
        let controller = RepositoriesViewController()
        controller.workspace = workspace
        controller.repository = repository
        controller.iconColor = prefs.preferences.general.fileIconStyle

        context.coordinator.controller = controller

        return controller
    }

    func updateNSViewController(_ nsViewController: RepositoriesViewController, context: Context) {
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
        }

        var listener: AnyCancellable?
        var workspace: WorkspaceDocument
        var controller: RepositoriesViewController?

        deinit {
            listener?.cancel()
        }
    }
}

// TODO: Nanashili (issued by Kai Tay): Remove dummy classes for repo and branch, replace with actual data
class DummyRepo {
    var isLocal: Bool
    var repoName: String
    var branches: [DummyBranch]
    var recentBranches: [DummyBranch]
    // i honestly have no clue what tags are :P
    var tags: [String]
    // IDK about this as well, im just using a string to represent its name
    var stashedChanges: [String]

    // sorry for the bad implementation. These are the Branches, Recent Locations, etc. containers
    // currently they're just a shared class. Ideally, they'd all be different classes with their
    // own data, so properties like branches, recentBranches, tags, stashedChanges would be in those
    // classes instead of the DummyRepo class.
    var containers: [DummyContainer] = [
        DummyContainer(type: .branches),
        DummyContainer(type: .recentLocations),
        DummyContainer(type: .tags),
        DummyContainer(type: .stashedChanges),
        DummyContainer(type: .remotes)
    ]

    var current: Int
    var remotes: [DummyRepo]

    init(repoName: String,
         branches: [DummyBranch],
         recentBranches: [DummyBranch] = [],
         tags: [String] = [],
         stashedChanges: [String] = [],
         current: Int = 0,
         remotes: [DummyRepo] = [],
         isLocal: Bool = true
    ) {
        self.repoName = repoName
        self.branches = branches
        self.isLocal = isLocal
        if isLocal {
            self.recentBranches = recentBranches
            self.tags = tags
            self.stashedChanges = stashedChanges
            self.current = current
            self.remotes = remotes
            self.remotes.forEach { $0.isLocal = false }
        } else {
            self.recentBranches = []
            self.tags = []
            self.stashedChanges = []
            self.current = 0
            self.remotes = []
        }
    }

    // a shared class for the containers like branches, tags, etc. because i don't wanna make classes for each one
    // they don't really hold anything but their name so who caressss
    class DummyContainer {
        var type: DummyContainerType

        enum DummyContainerType {
            case branches
            case recentLocations
            case tags
            case stashedChanges
            case remotes
        }

        init(type: DummyContainerType) {
            self.type = type
        }
    }

    class DummyBranch {
        var name: String

        init(name: String) {
            self.name = name
        }
    }
}
