//
//  SideBar.swift
//  AuroraEditor
//
//  Created by Lukas Pistrol on 17.03.22.
//

import SwiftUI

struct NavigatorSidebar: View {
    @ObservedObject
    private var workspace: WorkspaceDocument

    @StateObject
    var prefs: AppPreferencesModel = .shared

    private let windowController: NSWindowController

    @State
    public var selection: Int = 0

    @State
    private var dropProposal: SplitViewProposalDropPosition?

    private let toolbarPadding: Double = -8.0

    init(workspace: WorkspaceDocument, windowController: NSWindowController) {
        self.workspace = workspace
        self.windowController = windowController
    }

    var body: some View {
        VStack {
            switch selection {
            case 0:
                ProjectNavigator(workspace: workspace)
            case 1:
                SourceControlNavigatorView(workspace: workspace)
            case 2:
                FindNavigator(workspace: workspace, state: workspace.searchState ?? .init(workspace))
            case 3, 4, 5, 6:
                needsImplementation
            case 7:
                ExtensionNavigator(data: workspace.extensionNavigatorData!)
                    .environmentObject(workspace)
            default:
                Spacer()
            }
        }
        .splitView(availablePositions: [.top, .bottom, .center],
                   proposalPosition: $dropProposal,
                   margin: 0.25,
                   isProportional: true,
                   onDrop: { position in
            switch position {
            case .top:
                Log.info("Dropped at the top")
            case .bottom:
                Log.info("Dropped at the bottom")
            case .leading:
                Log.info("Dropped at the start")
            case .trailing:
                Log.info("Dropped at the end")
            case .center:
                Log.info("Dropped at the center")
            }
        })
        .ignoresSafeArea(edges: (prefs.preferences.general.sidebarStyle == .xcode) ? [.leading] : [])
        .padding([.top, .leading], (prefs.preferences.general.sidebarStyle == .xcode) ? 0 : -10)
        .safeAreaInset(edge: .leading) { // VSC style sidebar
            if prefs.preferences.general.sidebarStyle == .vscode {
                NavigatorSidebarToolbarLeft(selection: $selection)
                    .padding(.leading, 5)
                    .padding(.trailing, -3)
                    .safeAreaInset(edge: .trailing) {
                        // this complex thing is so that theres a vertical divider that goes from top to bottom
                        HStack {
                            GeometryReader { geometry in
                                Divider()
                                    .frame(height: geometry.size.height + 8)
                            }
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
                NavigatorSidebarToolbarTop(selection: $selection)
                    .padding(.bottom, toolbarPadding)
            } else {
                Divider()
            }
        }
        .safeAreaInset(edge: .bottom) {
            switch selection {
            case 0:
                ProjectNavigatorToolbarBottom(workspace: workspace)
                    .padding(.top, toolbarPadding)
            case 1:
                SourceControlToolbarBottom()
                    .padding(.top, toolbarPadding)
            case 2, 3, 4, 5, 6, 7:
                NavigatorSidebarToolbarBottom(workspace: workspace)
                    .padding(.top, toolbarPadding)
            default:
                NavigatorSidebarToolbarBottom(workspace: workspace)
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
