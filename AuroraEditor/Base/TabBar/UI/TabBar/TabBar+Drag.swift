//
//  TabBar+Drag.swift
//  Aurora Editor
//
//  Created by TAY KAI QUAN on 11/9/22.
//  Copyright © 2023 Aurora Company. All rights reserved.
//

import SwiftUI

extension TabBar {

    // Disable the rule because this function is implementing the drag gesture and its animations.
    // It is fairly complicated, so ignore the function body length limitation for now.
    // swiftlint:disable:next function_body_length cyclomatic_complexity
    func makeTabDragGesture(id: TabBarItemID) -> some Gesture {
        return DragGesture(minimumDistance: 2, coordinateSpace: .global)
            .onChanged({ value in
                if draggingTabId != id {
                    shouldOnDrag = false
                    draggingTabId = id
                    draggingStartLocation = value.startLocation.x
                    draggingLastLocation = value.location.x
                }
                // if the location is too far away on the Y axis from the start, get rid of the gesture.
                if abs(value.location.y - value.startLocation.y) > TabBar.height {
                    // toggling shouldOnDrag momentarily turns off the highPriorityGesture in TabBar.swift
                    // which should end the gesture forcefully.
                    shouldOnDrag = true
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1, execute: {
                        shouldOnDrag = false
                        draggingStartLocation = nil
                        draggingLastLocation = nil
                        draggingTabId = nil
                        withAnimation(.easeInOut(duration: 0.25)) {
                            tabOffsets = [:]
                        }
                    })
                    return
                }
                // Get the current cursor location.
                let currentLocation = value.location.x
                guard let startLocation = draggingStartLocation,
                      let currentIndex = openedTabs.firstIndex(of: id),
                      let currentTabWidth = tabWidth[id],
                      let lastLocation = draggingLastLocation
                else { return }
                let dragDifference = currentLocation - lastLocation
                let previousIndex = currentIndex > 0 ? currentIndex - 1 : nil
                let nextIndex = currentIndex < openedTabs.count - 1 ? currentIndex + 1 : nil
                tabOffsets[id] = currentLocation - startLocation

                // Interacting with the previous tab.
                if previousIndex != nil && dragDifference < 0 {
                    // Wrap `previousTabIndex` because it may be `nil`.
                    guard let previousTabIndex = previousIndex,
                          let previousTabLocation = tabLocations[openedTabs[previousTabIndex]],
                          let previousTabWidth = tabWidth[openedTabs[previousTabIndex]]
                    else { return }
                    if currentLocation < max(
                        previousTabLocation.maxX - previousTabWidth * 0.1,
                        previousTabLocation.minX + currentTabWidth * 0.9
                    ) {
                        let changing = previousTabWidth - 1 // One offset for overlapping divider.
                        draggingStartLocation! -= changing
                        withAnimation {
                            tabOffsets[id]! += changing
                            openedTabs.move(
                                fromOffsets: IndexSet(integer: previousTabIndex),
                                toOffset: currentIndex + 1
                            )
                        }
                        return
                    }
                }

                // Interacting with the next tab.
                if nextIndex != nil && dragDifference > 0 {
                    // Wrap `previousTabIndex` because it may be `nil`.
                    guard let nextTabIndex = nextIndex,
                          let nextTabLocation = tabLocations[openedTabs[nextTabIndex]],
                          let nextTabWidth = tabWidth[openedTabs[nextTabIndex]]
                    else { return }
                    if currentLocation > min(
                        nextTabLocation.minX + nextTabWidth * 0.1,
                        nextTabLocation.maxX - currentTabWidth * 0.9
                    ) {
                        let changing = nextTabWidth - 1 // One offset for overlapping divider.
                        draggingStartLocation! += changing
                        withAnimation {
                            tabOffsets[id]! -= changing
                            openedTabs.move(
                                fromOffsets: IndexSet(integer: nextTabIndex),
                                toOffset: currentIndex
                            )
                        }
                        return
                    }
                }

                // Only update the last dragging location when there is enough offset.
                if draggingLastLocation == nil || abs(value.location.x - draggingLastLocation!) >= 10 {
                    draggingLastLocation = value.location.x
                }
            })
            .onEnded({ _ in
                shouldOnDrag = false
                draggingStartLocation = nil
                draggingLastLocation = nil
                withAnimation(.easeInOut(duration: 0.25)) {
                    tabOffsets = [:]
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                    draggingTabId = nil
                }
                // Sync the workspace's `openedTabs` 150ms after animation is finished.
                // In order to avoid the lag due to the update of workspace state.
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.40) {
                    if draggingStartLocation == nil {
                        workspace.selectionState.openedTabs = openedTabs
                    }
                }
            })
    }

    func makeTabItemGeometryReader(id: TabBarItemID) -> some View {
            GeometryReader { tabItemGeoReader in
                Rectangle()
                    .foregroundColor(.clear)
                    .onAppear {
                        tabWidth[id] = tabItemGeoReader.size.width
                        tabLocations[id] = tabItemGeoReader
                            .frame(in: .global)
                    }
                    .onChange(
                        of: tabItemGeoReader.frame(in: .global),
                        perform: { tabCGRect in
                            tabLocations[id] = tabCGRect
                        }
                    )
                    .onChange(
                        of: tabItemGeoReader.size.width,
                        perform: { newWidth in
                            tabWidth[id] = newWidth
                        }
                    )
            }
        }

    struct TabBarItemOnDropDelegate: DropDelegate {
            private let currentTabId: TabBarItemID
            @Binding
            private var openedTabs: [TabBarItemID]
            @Binding
            private var onDragTabId: TabBarItemID?
            @Binding
            private var onDragLastLocation: CGPoint?
            @Binding
            private var isOnDragOverTabs: Bool
            @Binding
            private var tabWidth: [TabBarItemID: CGFloat]

            public init(
                currentTabId: TabBarItemID,
                openedTabs: Binding<[TabBarItemID]>,
                onDragTabId: Binding<TabBarItemID?>,
                onDragLastLocation: Binding<CGPoint?>,
                isOnDragOverTabs: Binding<Bool>,
                tabWidth: Binding<[TabBarItemID: CGFloat]>
            ) {
                self.currentTabId = currentTabId
                self._openedTabs = openedTabs
                self._onDragTabId = onDragTabId
                self._onDragLastLocation = onDragLastLocation
                self._isOnDragOverTabs = isOnDragOverTabs
                self._tabWidth = tabWidth
            }

            func dropEntered(info: DropInfo) {
                isOnDragOverTabs = true
                guard let onDragTabId = onDragTabId,
                      currentTabId != onDragTabId,
                      let from = openedTabs.firstIndex(of: onDragTabId),
                      let toIndex = openedTabs.firstIndex(of: currentTabId)
                else { return }
                if openedTabs[toIndex] != onDragTabId {
                    withAnimation {
                        openedTabs.move(
                            fromOffsets: IndexSet(integer: from),
                            toOffset: toIndex > from ? toIndex + 1 : toIndex
                        )
                    }
                }
            }

            func dropExited(info: DropInfo) {
                // Do nothing.
            }

            func dropUpdated(info: DropInfo) -> DropProposal? {
                return DropProposal(operation: .move)
            }

            func performDrop(info: DropInfo) -> Bool {
                isOnDragOverTabs = false
                onDragTabId = nil
                onDragLastLocation = nil
                return true
            }
        }
}
