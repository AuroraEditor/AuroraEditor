//
//  SideBar.swift
//  AuroraEditor
//
//  Created by Lukas Pistrol on 17.03.22.
//

import SwiftUI

struct NavigatorSidebar: View {
    @EnvironmentObject
    private var workspace: WorkspaceDocument

    @StateObject
    var prefs: AppPreferencesModel = .shared

    @State
    public var selections: [Int] = [0]

    @ObservedObject
    internal var model: NavigatorModeSelectModel = .shared

    @State
    private var dropProposal: SplitViewProposalDropPosition?

    private let toolbarPadding: Double = -8.0

    var body: some View {
        ForEach(Array(selections.enumerated()), id: \.offset) { index, _ in
            sidebarModule(toolbar: index)
        }
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
    }

    // swiftlint:disable:next function_body_length
    func sidebarModule(toolbar: Int) -> some View {
        VStack {
            switch selections[toolbar] {
            case 0:
                ProjectNavigator()
            case 1:
                SourceControlNavigatorView()
            case 2:
                FindNavigator(state: workspace.searchState ?? .init(workspace))
            case 6:
                HierarchyNavigator()
            case 7:
                ExtensionNavigator(data: workspace.extensionNavigatorData!)
                    .environmentObject(workspace)
            default:
                needsImplementation
            }
        }
        .ignoresSafeArea(edges: (prefs.preferences.general.sidebarStyle == .xcode) ? [.leading] : [])
        .padding([.top, .leading], (prefs.preferences.general.sidebarStyle == .xcode) ? 0 : -10)
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
            switch selections[toolbar] {
            case 0:
                ProjectNavigatorToolbarBottom()
                    .padding(.top, toolbarPadding)
            case 1:
                SourceControlToolbarBottom()
                    .padding(.top, toolbarPadding)
            case 2, 3, 4, 5, 6, 7:
                NavigatorSidebarToolbarBottom()
                    .padding(.top, toolbarPadding)
            default:
                NavigatorSidebarToolbarBottom()
                    .padding(.top, toolbarPadding)
            }
        }
    }

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
