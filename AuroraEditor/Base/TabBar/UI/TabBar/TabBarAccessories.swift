//
//  TabBarAccessories.swift
//  Aurora Editor
//
//  Created by TAY KAI QUAN on 10/9/22.
//  Copyright © 2023 Aurora Company. All rights reserved.
//

import SwiftUI

extension TabBar {
    // TabBar items on the left
    var leadingAccessories: some View {
        HStack(spacing: 2) {
            recentMenuButton
                .help("Navigate to Related Items")

            Divider()
                .padding(.vertical, 8)

            TabBarAccessoryIcon(
                icon: .init(systemName: "chevron.left"),
                action: {
                    let currentTab = workspace.selectionState.selectedId

                    guard let idx = workspace.selectionState.openedTabs.firstIndex(of: currentTab!) else { return }

                    if workspace.selectionState.selectedId == currentTab {
                        workspace.selectionState.selectedId = workspace.selectionState.openedTabs[idx - 1]
                    }
                }
            )
            .font(Font.system(size: 14, weight: .light, design: .default))
            .foregroundColor(.secondary)
            .disabled(workspace.selectionState.openedTabs.isEmpty || disableTabNavigationLeft())
            .buttonStyle(.plain)
            .help("Navigate back")

            TabBarAccessoryIcon(
                icon: .init(systemName: "chevron.right"),
                action: {
                    let currentTab = workspace.selectionState.selectedId

                    guard let idx = workspace.selectionState.openedTabs.firstIndex(of: currentTab!) else { return }

                    if workspace.selectionState.selectedId == currentTab {
                        workspace.selectionState.selectedId = workspace.selectionState.openedTabs[idx + 1]
                    }
                }
            )
            .font(Font.system(size: 14, weight: .light, design: .default))
            .foregroundColor(.secondary)
            .disabled(workspace.selectionState.openedTabs.isEmpty || disableTabNavigationRight())
            .buttonStyle(.plain)
            .help("Navigate forward")
        }
        .padding(.horizontal, 7)
        .opacity(activeState != .inactive ? 1.0 : 0.5)
        .frame(maxHeight: .infinity) // Fill out vertical spaces.
        .background {
            if prefs.preferences.general.tabBarStyle == .native {
                TabBarAccessoryNativeBackground(dividerAt: .trailing)
            }
        }
    }

    // TabBar items on right
    var trailingAccessories: some View {
        HStack(spacing: 2) {
            if let selectedId = workspace.selectionState.selectedId,
               selectedId.id.contains("codeEditor_") {
                TabBarAccessoryIcon(
                    icon: .init(systemName: "arrow.left.arrow.right"),
                    action: {
                    }
                )
                .font(Font.system(size: 10, weight: .light, design: .default))
                .foregroundColor(.secondary)
                .buttonStyle(.plain)
                .disabled(!prefs.sourceControlActive())
                .help("Enable Code Review")

                Menu {
                    textEditorMenu()
                } label: {
                    Image(systemName: "ellipsis.circle")
                        .font(Font.system(size: 14, weight: .light, design: .default))
                        .foregroundColor(.secondary)
                }
                .buttonStyle(.plain)
                .help("Options")

                Divider()
                    .padding(.vertical, 8)
            }

            ToolbarPlusMenu(workspace: workspace)
                .foregroundColor(.secondary)
                .help("Open New Web Tab")

            TabBarAccessoryIcon(
                icon: .init(systemName: "square.split.2x1"),
                action: {
                    /* TODO */
                }
            )
            .font(Font.system(size: 14, weight: .light, design: .default))
            .foregroundColor(.secondary)
            .buttonStyle(.plain)
            .help("Split View")
        }
        .padding(.horizontal, 7)
        .opacity(activeState != .inactive ? 1.0 : 0.5)
        .frame(maxHeight: .infinity) // Fill out vertical spaces.
        .background {
            if prefs.preferences.general.tabBarStyle == .native {
                TabBarAccessoryNativeBackground(dividerAt: .leading)
            }
        }
    }

    // If the currently selected tab is the first item in
    // the list we disable the left navigation button otherwise
    // if it's > 0 we enable it.
    private func disableTabNavigationLeft() -> Bool {
        let openedTabs = workspace.selectionState.openedTabs
        let currentTab = workspace.selectionState.selectedId
        let tabPosition = openedTabs.firstIndex {
            $0 == currentTab
        }

        if tabPosition == 0 {
            return true
        }

        return false
    }

    // Disables the right navigation button when the current tab
    // is the last item in the list, if the current item is not the
    // last item we re-enable it allowing the user to navigate forward
    // of any open tabs they may have.
    private func disableTabNavigationRight() -> Bool {
        let openedTabs = workspace.selectionState.openedTabs
        let currentTab = workspace.selectionState.selectedId

        if currentTab == openedTabs.last {
            return true
        }

        return false
    }

    private var recentMenuButton: some View {
        VStack {
            if #available(macOS 13, *) {
                Menu {
                    Menu {
                        ForEach(sourceControlModel.changed) { item in
                            Button {

                            } label: {
                                Image(systemName: item.systemImage)
                                    .foregroundColor(item.iconColor)
                                Text(item.fileName)
                            }
                        }
                        Divider()
                        Button {
                        } label: {
                            Text("Clear Menu")
                        }
                    } label: {
                        Text("Recent Files")
                    }

                    Menu {
                        ForEach(sourceControlModel.changed) { item in
                            Button {
                                workspace.openTab(item: item)
                            } label: {
                                Image(systemName: item.systemImage)
                                    .foregroundColor(item.iconColor)
                                Text(item.fileName)
                            }
                        }
                    } label: {
                        Text("Locally Modified Files")
                    }
                } label: {
                    Image(systemName: "square.grid.2x2")
                }
                .buttonStyle(.plain)
            } else {
                Menu {
                    Menu {
                        ForEach(sourceControlModel.changed) { item in
                            Button {

                            } label: {
                                Image(systemName: item.systemImage)
                                    .foregroundColor(item.iconColor)
                                Text(item.fileName)
                            }
                        }
                        Divider()
                        Button {
                        } label: {
                            Text("Clear Menu")
                        }
                    } label: {
                        Text("Recent Files")
                    }

                    Menu {
                        ForEach(sourceControlModel.changed) { item in
                            Button {
                                workspace.openTab(item: item)
                            } label: {
                                Image(systemName: item.systemImage)
                                    .foregroundColor(item.iconColor)
                                Text(item.fileName)
                            }
                        }
                    } label: {
                        Text("Locally Modified Files")
                    }
                } label: {
                    Image(systemName: "square.grid.2x2")
                }
                .menuStyle(.borderlessButton)
                .buttonStyle(.plain)
                .menuIndicator(.hidden)
                .frame(width: 20)
            }
        }
    }

    private func textEditorMenu() -> some View {
        VStack {
            Button {
                prefs.preferences.textEditing.showMinimap.toggle()
            } label: {
                Text("Show Editor Only")
                    .font(.system(size: 11))
            }
            .keyboardShortcut(.return, modifiers: [.command])

            Divider()

            Toggle(isOn: .constant(false)) {
                Text("Inline Comparison")
                    .font(.system(size: 11))
            }

            Toggle(isOn: .constant(false)) {
                Text("Side By Side Comparison")
                    .font(.system(size: 11))
            }

            Divider()

            Group {
                Toggle(isOn: $prefs.preferences.textEditing.showMinimap) {
                    Text("Minimap")
                        .font(.system(size: 11))
                }
                .keyboardShortcut("M", modifiers: [.control, .shift, .command])

                Toggle(isOn: .constant(false)) {
                    Text("Authors")
                        .font(.system(size: 11))
                }
                .keyboardShortcut("A", modifiers: [.control, .shift, .command])

                Toggle(isOn: .constant(false)) {
                    Text("Code Coverage")
                        .font(.system(size: 11))
                }
            }

            Divider()

            Group {
                Toggle(isOn: .constant(false)) {
                    Text("Invisibles")
                        .font(.system(size: 11))
                }

                Toggle(isOn: .constant(false)) {
                    Text("Wrap Lines")
                        .font(.system(size: 11))
                }
                .keyboardShortcut("L", modifiers: [.control, .shift, .command])
            }
        }
    }

}
