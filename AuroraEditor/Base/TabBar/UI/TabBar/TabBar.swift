//
//  TabBar.swift
//  AuroraEditor
//
//  Created by Lukas Pistrol on 17.03.22.
//

import SwiftUI

struct TabBar: View {
    /// The height of tab bar.
    /// I am not making it a private variable because it may need to be used in outside views.
    static let height = 28.0

    @Environment(\.colorScheme)
    private var colorScheme

    @Environment(\.controlActiveState)
    var activeState

    private let windowController: NSWindowController

    @ObservedObject
    var workspace: WorkspaceDocument

    @ObservedObject
    var sourceControlModel: SourceControlModel

    @StateObject
    var prefs: AppPreferencesModel = .shared

    // TabBar(windowController: windowController, workspace: workspace)
    init(windowController: NSWindowController, workspace: WorkspaceDocument) {
        self.windowController = windowController
        self.workspace = workspace
        self.sourceControlModel = workspace.fileSystemClient?.model ?? .init(workspaceURL: workspace.fileURL!)
    }

    @State
    var expectedTabWidth: CGFloat = 0

    /// This state is used to detect if the mouse is hovering over tabs.
    /// If it is true, then we do not update the expected tab width immediately.
    @State
    var isHoveringOverTabs: Bool = false

    private func updateExpectedTabWidth(proxy: GeometryProxy) {
        expectedTabWidth = max(
            // Equally divided size of a native tab.
            (proxy.size.width + 1) / CGFloat(workspace.selectionState.openedTabs.count) + 1,
            // Min size of a native tab.
            CGFloat(140)
        )
    }

    /// Conditionally updates the `expectedTabWidth`.
    /// Called when the tab count changes or the temporary tab changes.
    /// - Parameter geometryProxy: The geometry proxy to calculate the new width using.
    private func updateForTabCountChange(geometryProxy: GeometryProxy) {
        // Only update the expected width when user is not hovering over tabs.
        // This should give users a better experience on closing multiple tabs continuously.
        if !isHoveringOverTabs {
            withAnimation(.easeOut(duration: 0.15)) {
                updateExpectedTabWidth(proxy: geometryProxy)
            }
        }
    }

    var body: some View {
        HStack(alignment: .center, spacing: 0) {
            // Tab bar navigation control.
            leadingAccessories
            // Tab bar items.
            GeometryReader { geometryProxy in
                ScrollView(.horizontal, showsIndicators: false) {
                    ScrollViewReader { scrollReader in
                        HStack(
                            alignment: .center,
                            spacing: -1
                        ) {
                            ForEach(workspace.selectionState.openedTabs, id: \.id) { id in
                                if let item = workspace.selectionState.getItemByTab(id: id) {
                                    TabBarItem(
                                        expectedWidth: $expectedTabWidth,
                                        item: item,
                                        windowController: windowController,
                                        workspace: workspace
                                    )
                                    .frame(height: TabBar.height)
                                }
                            }
                        }
                        // This padding is to hide dividers at two ends under the accessory view divider.
                        .padding(.horizontal, prefs.preferences.general.tabBarStyle == .native ? -1 : 0)
                        .onAppear {
                            // On view appeared, compute the initial expected width for tabs.
                            updateExpectedTabWidth(proxy: geometryProxy)
                            // On first tab appeared, jump to the corresponding position.
                            scrollReader.scrollTo(workspace.selectionState.selectedId)
                        }
                        // When selected tab is changed, scroll to it if possible.
                        .onChange(of: workspace.selectionState.selectedId) { targetId in
                            guard let selectedId = targetId else { return }
                            scrollReader.scrollTo(selectedId)
                        }
                        // When tabs are changing, re-compute the expected tab width.
                        .onChange(of: workspace.selectionState.openedTabs.count) { _ in
                            updateForTabCountChange(geometryProxy: geometryProxy)
                        }
                        .onChange(of: workspace.selectionState.temporaryTab, perform: { _ in
                            updateForTabCountChange(geometryProxy: geometryProxy)
                        })
                        // When window size changes, re-compute the expected tab width.
                        .onChange(of: geometryProxy.size.width) { _ in
                            updateExpectedTabWidth(proxy: geometryProxy)
                        }
                        // When user is not hovering anymore, re-compute the expected tab width immediately.
                        .onHover { isHovering in
                            isHoveringOverTabs = isHovering
                            if !isHovering {
                                withAnimation(.easeOut(duration: 0.15)) {
                                    updateExpectedTabWidth(proxy: geometryProxy)
                                }
                            }
                        }
                        .frame(height: TabBar.height)
                    }
                }
                // When there is no opened file, hide the scroll view, but keep the background.
                .opacity(
                    workspace.selectionState.openedTabs.isEmpty && workspace.selectionState.temporaryTab == nil
                    ? 0.0
                    : 1.0
                )
                // To fill up the parent space of tab bar.
                .frame(maxWidth: .infinity)
                .background {
                    if prefs.preferences.general.tabBarStyle == .native {
                        TabBarNativeInactiveBackground()
                    }
                }
            }
            // Tab bar tools (e.g. split view).
            trailingAccessories
        }
        .frame(height: TabBar.height)
        .overlay(alignment: .top) {
            // When tab bar style is `xcode`, we put the top divider as an overlay.
            if prefs.preferences.general.tabBarStyle == .xcode {
                TabBarTopDivider()
            }
        }
        .background {
            if prefs.preferences.general.tabBarStyle == .xcode {
                TabBarXcodeBackground()
            }
        }
        .background {
            if prefs.preferences.general.tabBarStyle == .xcode {
                EffectView(
                    NSVisualEffectView.Material.titlebar,
                    blendingMode: NSVisualEffectView.BlendingMode.withinWindow
                )
                // Set bottom padding to avoid material overlapping in bar.
                .padding(.bottom, TabBar.height)
                .edgesIgnoringSafeArea(.top)
            } else {
                TabBarNativeMaterial()
                    .edgesIgnoringSafeArea(.top)
            }
        }
        .padding(.leading, -1)
    }
}
