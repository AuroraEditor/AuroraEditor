//
//  AuroraSplitViewController.swift
//  Aurora Editor
//
//  Created by Fumiya Tanaka on 2023/02/12.
//  Copyright © 2023 Aurora Company. All rights reserved.
//

import AppKit
import Combine

/// AuroraSplitViewController
///
/// `AuroraSplitViewController` is defined so that we observe resize event for SplitView subViews.
/// By observing such a resize event, we can memorize latest size of
/// ``NavigatorSidebar``/``WorkspaceView`` /``InspectorSidebar``
/// whose sizes are stored inside ``AppPreferences/GeneralPreferences``.
class AuroraSplitViewController: NSSplitViewController {

    let prefs: AppPreferencesModel

    /// - Note: Before calling viewDidAppear, received size is kind of minimum size.
    /// because it is not what user intends, we would like to skip such a default value to be persisted.
    private var calledViewDidAppear: Bool = false

    /// `generalPrefsSubject` stores latest size change of each splitViewItem.
    ///
    /// Why `generalPrefsSubject` exists is because such a frequest size change like splitViewItem
    ///  should not be persisted one by one.
    /// rather than that, we would like to store only the latest event of size change
    /// by using `Publiher.debounce` in `Combine` framework.
    private let generalPrefsSubject: PassthroughSubject<AppPreferences.GeneralPreferences, Never> = .init()

    private var cancellables: Set<AnyCancellable> = []

    init(prefs: AppPreferencesModel) {
        self.prefs = prefs
        super.init(nibName: nil, bundle: nil)

        generalPrefsSubject.debounce(for: 0.3, scheduler: DispatchQueue.main)
            .sink { [weak prefs] general in
                guard let prefs else {
                    return
                }
                /// Note: in case, other stuff of ``AppPreferences/GeneralPreferences`` is updated,
                /// we only update the properties which can be updated in ``AuroraSplitViewController``.
                prefs.preferences.general.navigationSidebarWidth = general.navigationSidebarWidth
                prefs.preferences.general.workspaceSidebarWidth = general.workspaceSidebarWidth
                prefs.preferences.general.inspectorSidebarWidth = general.inspectorSidebarWidth
            }
            .store(in: &cancellables)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidAppear() {
        super.viewDidAppear()
        calledViewDidAppear = true
    }

    override func splitViewDidResizeSubviews(_ notification: Notification) {
        if !calledViewDidAppear {
            return
        }
        // Workaround
        // this method `splitViewDidResizeSubviews` is also called when current window is about to be closed.
        // then, somehow splitViewItem size is not correct (like set to zero).
        // so I would like to skip the case some of the splitViewItems has zero size.
        guard splitView.subviews.isEmpty == false, splitView.subviews.allSatisfy({ $0.frame.width != .zero }) else {
            return
        }
        let prefsKeyPath: [WritableKeyPath<AppPreferences.GeneralPreferences, Double>] = [
            \.navigationSidebarWidth,
            \.workspaceSidebarWidth,
            \.inspectorSidebarWidth
        ]
        let subViews = [
            splitView.subviews[0],
            splitView.subviews[1],
            splitView.subviews[2]
        ]
        var general = prefs.preferences.general
        for (sidebar, keyPath) in zip(subViews, prefsKeyPath) {
            let width = sidebar.frame.size.width
            general[keyPath: keyPath] = width
        }
        generalPrefsSubject.send(general)
    }
}
