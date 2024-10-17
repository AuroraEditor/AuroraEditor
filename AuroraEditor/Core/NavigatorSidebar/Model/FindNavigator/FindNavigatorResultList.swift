//
//  SearchResultList.swift
//  Aurora Editor
//
//  Created by Ziyuan Zhao on 2022/3/22.
//  Copyright © 2023 Aurora Company. All rights reserved.
//

import SwiftUI
import Combine

/// The view that displays the search results in the navigator.
struct FindNavigatorResultList: NSViewControllerRepresentable {
    /// The workspace document
    @EnvironmentObject
    var workspace: WorkspaceDocument

    /// The application preferences model
    @StateObject
    var prefs: AppPreferencesModel = .shared

    typealias NSViewControllerType = FindNavigatorListViewController

    /// Make the view controller
    /// 
    /// - Parameter context: the context
    /// 
    /// - Returns: the view controller
    func makeNSViewController(context: Context) -> FindNavigatorListViewController {
        let controller = FindNavigatorListViewController(workspace: workspace)
        controller.setSearchResults(workspace.searchState?.searchResult ?? [])
        controller.rowHeight = prefs.preferences.general.projectNavigatorSize.rowHeight
        context.coordinator.controller = controller
        return controller
    }

    /// Update the view controller
    /// 
    /// - Parameter nsViewController: the view controller
    /// - Parameter context: the context
    func updateNSViewController(_ nsViewController: FindNavigatorListViewController, context: Context) {
        nsViewController.updateNewSearchResults(workspace.searchState?.searchResult ?? [],
                                                searchId: workspace.searchState?.searchId)
        if nsViewController.rowHeight != prefs.preferences.general.projectNavigatorSize.rowHeight {
            nsViewController.rowHeight = prefs.preferences.general.projectNavigatorSize.rowHeight
        }

        return
    }

    /// Make the coordinator
    func makeCoordinator() -> Coordinator {
        Coordinator(state: workspace.searchState, controller: nil)
    }

    /// The coordinator
    class Coordinator: NSObject {
        /// Initialize a new coordinator
        /// 
        /// - Parameter state: the search state
        /// - Parameter controller: the controller
        /// 
        /// - Returns: a new coordinator
        @MainActor
        init(state: WorkspaceDocument.SearchState?, controller: FindNavigatorListViewController?) {
            self.controller = controller
            super.init()
            self.listener = state?
                .searchResult
                .publisher
                .receive(on: RunLoop.main)
                .collect()
                .sink(receiveValue: { [weak self] searchResults in
                    self?.controller?.updateNewSearchResults(searchResults, searchId: state?.searchId)
                })
        }

        /// The listener
        var listener: AnyCancellable?

        /// The controller
        var controller: FindNavigatorListViewController?

        /// Deinitialize
        deinit {
            controller = nil
            listener?.cancel()
            listener = nil
        }
    }
}
