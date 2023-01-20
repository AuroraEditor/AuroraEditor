//
//  TabBar.swift
//  Aurora Editor
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

    @EnvironmentObject
    var workspace: WorkspaceDocument

    @ObservedObject
    var sourceControlModel: SourceControlModel

    @StateObject
    var prefs: AppPreferencesModel = .shared

    @State
    var expectedTabWidth: CGFloat = 0

    /// This state is used to detect if the mouse is hovering over tabs.
    /// If it is true, then we do not update the expected tab width immediately.
    @State
    var isHoveringOverTabs: Bool = false

    /// This state is used to detect if the dragging type should be changed from DragGesture to OnDrag.
    /// It is basically switched when vertical displacement is exceeding the threshold.
    @State
    var shouldOnDrag: Bool = false

    /// When it is true, then the `onDrag` is over the tabs, then we leave the space for dragged tab.
    /// When it is false, then the dragging cursor is outside the tab bar, then we should shrink the space.
    ///
    /// - TODO: The change of this state is overall incorrect. Should move it into workspace state.
    @State
    var isOnDragOverTabs: Bool = false

    /// The last location of `onDrag`.
    ///
    /// It can be used on reordering algorithm of `onDrag` (detecting when should we switch two tabs).
    @State
    var onDragLastLocation: CGPoint?

    /// The tab id of current dragging tab.
    ///
    /// It will be `nil` when there is no tab dragged currently.
    @State
    var draggingTabId: TabBarItemID?

    @State
    var onDragTabId: TabBarItemID?

    /// The start location of dragging.
    ///
    /// When there is no tab being dragged, it will be `nil`.
    /// - TODO: Check if `value.startLocation` is reliable
    @State
    var draggingStartLocation: CGFloat?

    /// The last location of dragging.
    ///
    /// This is used to determine the dragging direction.
    /// - TODO: Check if `value.translation` is usable
    @State
    var draggingLastLocation: CGFloat?

    /// Current opened tabs.
    ///
    /// This is a copy of `workspace.selectionState.openedTabs`.
    /// A copy will hugely improve the dragging performance, as updating ObservedObject too often will generate lags.
    @State
    var openedTabs: [TabBarItemID] = []

    /// A map of tab width.
    ///
    /// All width are measured dynamically (so it can also fit the Xcode tab bar style).
    /// This is used to be added on the offset of current dragging tab in order to make a smooth
    /// dragging experience.
    @State
    var tabWidth: [TabBarItemID: CGFloat] = [:]

    /// A map of tab location (CGRect).
    ///
    /// All locations are measured dynamically.
    /// This is used to compute when we should swap two tabs based on current cursor location.
    @State
    var tabLocations: [TabBarItemID: CGRect] = [:]

    /// A map of tab offsets.
    ///
    /// This is used to determine the tab offset of every tab (by their tab id) while dragging.
    @State
    var tabOffsets: [TabBarItemID: CGFloat] = [:]

    /// Update the expected tab width when corresponding UI state is updated.
    ///
    /// This function will be called when the number of tabs or the parent size is changed.
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
                            ForEach(openedTabs, id: \.id) { id in
                                if let item = workspace.selectionState.getItemByTab(id: id) {
                                    TabBarItem(
                                        expectedWidth: $expectedTabWidth,
                                        item: item
                                    )
                                    .frame(height: TabBar.height)
                                    .background(makeTabItemGeometryReader(id: id))
                                    // TODO: Detect the onDrag outside of tab bar.
                                    // When a tab is dragged out, we shrink the space of it.
                                    .padding(
                                        .trailing,
                                        !isOnDragOverTabs && onDragTabId == id ? (-tabWidth[id]! + 1) : 0
                                    )
                                    .offset(x: tabOffsets[id] ?? 0, y: 0)
                                    .highPriorityGesture(
                                        makeTabDragGesture(id: id),
                                        including: shouldOnDrag ? .subviews : .all
                                    )
                                    // Detect the drop action of each tab.
                                    .onDrop(
                                        of: [.utf8PlainText], // TODO: Make a unique type for it.
                                        delegate: TabBarItemOnDropDelegate(
                                            currentTabId: id,
                                            openedTabs: $openedTabs,
                                            onDragTabId: $onDragTabId,
                                            onDragLastLocation: $onDragLastLocation,
                                            isOnDragOverTabs: $isOnDragOverTabs,
                                            tabWidth: $tabWidth
                                        )
                                    )
                                }
                            }
                        }
                        // This padding is to hide dividers at two ends under the accessory view divider.
                        .padding(.horizontal, prefs.preferences.general.tabBarStyle == .native ? -1 : 0)
                        .onAppear {
                            openedTabs = workspace.selectionState.openedTabs
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
                        .onChange(of: workspace.selectionState.openedTabs) { _ in
                            openedTabs = workspace.selectionState.openedTabs
                            updateForTabCountChange(geometryProxy: geometryProxy)
                        }
                        .onChange(of: workspace.selectionState.temporaryTab, perform: { _ in
                            Log.info("Temp tab changed")
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
