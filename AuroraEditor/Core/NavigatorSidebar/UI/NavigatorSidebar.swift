//
//  SideBar.swift
//  Aurora Editor
//
//  Created by Lukas Pistrol on 17.03.22.
//  Copyright © 2023 Aurora Company. All rights reserved.
//

import SwiftUI
import OSLog

/// The sidebar of the navigator.
struct NavigatorSidebar: View {

    /// Workspace document
    @EnvironmentObject
    private var workspace: WorkspaceDocument

    @EnvironmentObject
    private var versionControl: VersionControlModel

    /// Application preferences model
    @StateObject
    var prefs: AppPreferencesModel = .shared

    /// Selections
    @State
    public var selections: [Int] = [0]

    /// Navigator mode select model
    @ObservedObject
    internal var model: NavigatorModeSelectModel = .shared

    /// Drop proposal
    @State
    private var dropProposal: SplitViewProposalDropPosition?

    /// Toolbar padding
    private let toolbarPadding: Double = -8.0

    /// Logger
    let logger = Logger(subsystem: "com.auroraeditor", category: "Navigator Sidebar")

    /// The view body.
    var body: some View {
        ForEach(Array(selections.enumerated()), id: \.offset) { index, _ in
            sidebarModule(toolbar: index)
        }
        .padding(.top, prefs.preferences.general.sidebarStyle == .xcode ? -30 : 0)
        .padding(.leading, prefs.preferences.general.sidebarStyle == .vscode ? -30 : 0)
        .splitView(availablePositions: [.top, .bottom, .center],
                   proposalPosition: $dropProposal,
                   margin: 0.35,
                   isProportional: true,
                   onDrop: { position, _ in
            // get the data
            if let draggingItem = model.draggingItem {
                moveIcon(draggingItem, to: position)
            }
        })
        .padding(.top, prefs.preferences.general.sidebarStyle == .xcode ? 30 : 0)
        .padding(.leading, prefs.preferences.general.sidebarStyle == .vscode ? 30 : 0)
        .onAppear {
            NotificationCenter.default.addObserver(
                forName: .changeNavigatorPane,
                object: nil,
                queue: OperationQueue.main
            ) { (notification) in
                if let pane = notification.object as? Int {
                    self.selections = [pane]
                }
            }
        }
    }

    /// Sidebar module
    /// 
    /// - Parameter toolbar: The toolbar number
    /// 
    /// - Returns: The sidebar module.
    func sidebarModule(toolbar: Int) -> some View {
        // swiftlint:disable:previous function_body_length
        sidebarModuleContent(toolbar: toolbar)
        .safeAreaInset(edge: .leading) { // VSC style sidebar
            if prefs.preferences.general.sidebarStyle == .vscode {
                NavigatorSidebarToolbar(selection: $selections[toolbar],
                                        style: $prefs.preferences.general.sidebarStyle,
                                        toolbarNumber: toolbar)
                .id("navToolbar")
                .safeAreaInset(edge: .trailing) {
                    // this complex thing is so that theres a vertical divider that goes from top to bottom
                    HStack {
                        Divider()
                            .padding(.bottom, -8)
                    }
                    .frame(width: 1)
                    .offset(x: -2, y: -8)
                }
            } else {
                HStack {
                }.frame(width: 0)
            }
        }
        .safeAreaInset(edge: .top) { // Xcode style sidebar
            if prefs.preferences.general.sidebarStyle == .xcode {
                NavigatorSidebarToolbar(selection: $selections[toolbar],
                                        style: $prefs.preferences.general.sidebarStyle,
                                        toolbarNumber: toolbar)
                .id("navToolbar")
                .padding(.bottom, toolbarPadding)
            } else {
                Divider()
            }
        }
        .safeAreaInset(edge: .bottom) {
            ZStack {
                switch selections[toolbar] {
                case 0:
                    ProjectNavigatorToolbarBottom()
                case 1:
                    SourceControlToolbarBottom()
                case 5:
                    if prefs.preferences.notifications.notificationsEnabled {
                        NotificationsNavigatorToolbarBottom()
                    } else {
                        EmptyView()
                    }
                case 2, 3, 4, 6, 7:
                    NavigatorSidebarToolbarBottom()
                default:
                    NavigatorSidebarToolbarBottom()
                }
            }
            .padding(.top, toolbarPadding)
            .padding(.bottom, (toolbar == 0 && selections.count == 2) ? -9 : 0)
        }
    }

    /// Sidebar module content
    /// 
    /// - Parameter toolbar: The toolbar number
    /// 
    /// - Returns: The sidebar module content.
    func sidebarModuleContent(toolbar: Int) -> some View {
        VStack {
            switch selections[toolbar] {
            case 0: ProjectNavigator()
            case 1: SourceControlNavigatorView(workspace: workspace)
                    .environmentObject(versionControl)
            case 2: FindNavigator(state: workspace.searchState ?? .init(workspace))
            case 5: NotificationsNavigatorView()
            case 6: HierarchyNavigator()
            case 7:
                if let extensionNavigatorData = workspace.extensionNavigatorData {
                    ExtensionNavigator(data: extensionNavigatorData)
                        .environmentObject(workspace)
                }
            default:
                needsImplementation
            }
        }
        .ignoresSafeArea(edges: (prefs.preferences.general.sidebarStyle == .xcode) ? [.leading] : [])
        .padding([.top, .leading], (prefs.preferences.general.sidebarStyle == .xcode) ? 0 : -10)
    }

    /// Needs implementation view
    var needsImplementation: some View {
        VStack(alignment: .center) {
            HStack {
                Spacer()
                Text("Needs Implementation")
                Spacer()
            }
        }
        .frame(maxHeight: .infinity)
    }
}
