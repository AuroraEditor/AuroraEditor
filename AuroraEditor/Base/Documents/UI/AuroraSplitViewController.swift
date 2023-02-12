//
//  AuroraSplitViewController.swift
//  Aurora Editor
//
//  Created by Fumiya Tanaka on 2023/02/12.
//  Copyright © 2023 Aurora Company. All rights reserved.
//

import Cocoa

/// AuroraSplitViewController
///
/// `AuroraSplitViewController` is defined so that we observe resize event for SplitViewI subViews.
/// By observing such a resize event, we can memorize latest size of ``InspectorSidebar`` .
/// ``InspectorSidebar`` size is stored inside ``AppPreferences/GeneralPreferences/inspectorSidebarWidth``.
class AuroraSplitViewController: NSSplitViewController {

    let prefs: AppPreferencesModel

    /// - Note: Before calling viewDidAppear, received size is kind of minimum size.
    /// because it is not what user intends, we would like to skip such a default value to be persisted.
    private var calledViewDidAppear: Bool = false

    init(prefs: AppPreferencesModel) {
        self.prefs = prefs
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidAppear() {
        super.viewDidAppear()
        calledViewDidAppear = true
    }

    override func splitViewDidResizeSubviews(_ notification: Notification) {
        guard let dividerIndex = notification.userInfo?["NSSplitViewDividerIndex"] as? Int else {
            return
        }
        if !calledViewDidAppear {
            return
        }
        var prefsKeyPath: [WritableKeyPath<AppPreferences, Double>] = []
        var subViews: [NSView] = []
        if dividerIndex == 0 {
            prefsKeyPath = [
                \AppPreferences.general.navigationSidebarWidth,
                \AppPreferences.general.workspaceSidebarWidth
            ]
            subViews = [
                splitView.subviews[0],
                splitView.subviews[1]
            ]
        } else if dividerIndex == 1 {
            prefsKeyPath = [
                \AppPreferences.general.workspaceSidebarWidth,
                \AppPreferences.general.inspectorSidebarWidth
            ]
            subViews = [
                splitView.subviews[1],
                splitView.subviews[2]
            ]
        } else {
            return
        }
        for (sidebar, keyPath) in zip(subViews, prefsKeyPath) {
            let width = sidebar.frame.size.width
            prefs.preferences[keyPath: keyPath] = width
        }
    }
}
