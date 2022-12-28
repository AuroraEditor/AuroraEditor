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
    private var model: NavigatorModeSelectModel = .shared

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

    func moveIcon(_ icon: SidebarDockIcon, to position: SplitViewProposalDropPosition) {
        // determine the toolbar that owns the icon
        // and also short circuit if the owner is not 0 or 1, as there should not
        // be any more than two at any given point
        guard let iconOwner = model.icons.firstIndex(where: { icons in
            icons.contains(where: { $0.id == icon.id })
        }), iconOwner >= 0 && iconOwner <= 1 else { return }

        // if the item was dragged to the top from the bottom, move it
        if iconOwner == 0 && position == .bottom {
            defer {
                // select a new focus for the top toolbar
                Log.info("Focusing new icon: \(icon.id) \(icon.title)")
                selections[0] = model.icons[0][0].id
            }
            // create the second toolbar if it does not exist
            if selections.count == 1 {
                selections.append(icon.id)
            }

            // remove the icon from its origin
            model.icons[0].removeAll { otherIcon in
                otherIcon.id == icon.id
            }

            // if the model does not have a second row, create it.
            guard model.icons.count == 2 else {
                model.icons.append([icon])
                return
            }

            // else, append the icon to the end of the second row
            model.icons[1].append(icon)
            selections[1] = icon.id

            // trim the top toolbar if its blank
            if model.icons[0].isEmpty {
                model.icons.remove(at: 0)
                selections.remove(at: 0)
            }

            return
        }

        // if the item was dragged to the bottom from the top, move it
        if iconOwner == 1 && position == .top {
            // remove the icon from its origin
            model.icons[1].removeAll { otherIcon in
                otherIcon.id == icon.id
            }

            // append the icon to the end of the first row
            model.icons[0].append(icon)
            selections[0] = icon.id

            // trim the bottom toolbar if its blank
            if model.icons[1].isEmpty {
                model.icons.remove(at: 1)
                selections.remove(at: 1)
            } else {
                // select a new focus for the bottom toolbar
                selections[1] = model.icons[1][0].id
            }
        }

        // if the item was dragged from top to top or bottom to bottom, select it
        if (iconOwner == 0 && position == .top) ||
           (iconOwner == 1 && position == .bottom) {
            selections[iconOwner] = icon.id
        }

        // if the item was dragged to the center, combine both toolbars
        if position == .center {
            model.icons = [Array(model.icons.joined())]
            selections = [icon.id]
        }
    }
}
