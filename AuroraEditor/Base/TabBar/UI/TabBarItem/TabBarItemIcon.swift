//
//  TabBarItemIcon.swift
//  AuroraEditor
//
//  Created by TAY KAI QUAN on 10/9/22.
//  Copyright © 2022 Aurora Company. All rights reserved.
//

import SwiftUI

extension TabBarItem {
    @ViewBuilder
    var iconTextView: some View {
        HStack(alignment: .center, spacing: 5) {
            item.icon
                .resizable()
                .aspectRatio(contentMode: .fit)
                .foregroundColor(
                    prefs.preferences.general.fileIconStyle == .color && activeState != .inactive
                    ? item.iconColor
                    : .secondary
                )
                .frame(width: 12, height: 12)
            Text(item.title)
                .font(
                    isTemporary
                    ? .system(size: 11.0).italic()
                    : .system(size: 11.0)
                )
                .lineLimit(1)
        }
        .frame(
            // To horizontally max-out the given width area ONLY in native tab bar style.
            maxWidth: prefs.preferences.general.tabBarStyle == .native ? .infinity : nil,
            // To max-out the parent (tab bar) area.
            maxHeight: .infinity
        )
        .padding(.horizontal, prefs.preferences.general.tabBarStyle == .native ? 28 : 23)
        .overlay {
            ZStack {
                if isActive {
                    // Close Tab Shortcut:
                    // Using an invisible button to contain the keyboard shortcut is simply
                    // because the keyboard shortcut has an unexpected bug when working with
                    // custom buttonStyle. This is an workaround and it works as expected.
                    Button(
                        action: closeAction,
                        label: { EmptyView() }
                    )
                    .frame(width: 0, height: 0)
                    .padding(0)
                    .opacity(0)
                    .keyboardShortcut("w", modifiers: [.command])
                }
                // Switch Tab Shortcut:
                // Using an invisible button to contain the keyboard shortcut is simply
                // because the keyboard shortcut has an unexpected bug when working with
                // custom buttonStyle. This is an workaround and it works as expected.
                Button(
                    action: switchAction,
                    label: { EmptyView() }
                )
                .frame(width: 0, height: 0)
                .padding(0)
                .opacity(0)
                .keyboardShortcut(
                    workspace.getTabKeyEquivalent(item: item),
                    modifiers: [.command]
                )
                .background(.blue)
                // Close button.
                Button(action: closeAction) {
                    if prefs.preferences.general.tabBarStyle == .xcode {
                        Image(systemName: "xmark")
                            .font(.system(size: 11.2, weight: .regular, design: .rounded))
                            .frame(width: 16, height: 16)
                            .foregroundColor(
                                isActive
                                ? (
                                    colorScheme == .dark
                                    ? .primary
                                    : Color(nsColor: .controlAccentColor)
                                )
                                : .secondary.opacity(0.80)
                            )
                    } else {
                        Image(systemName: "xmark")
                            .font(.system(size: 9.5, weight: .medium, design: .rounded))
                            .frame(width: 16, height: 16)
                    }
                }
                .buttonStyle(.borderless)
                .foregroundColor(isPressingClose ? .primary : .secondary)
                .background(
                    colorScheme == .dark
                    ? Color(nsColor: .white)
                        .opacity(isPressingClose ? 0.32 : isHoveringClose ? 0.18 : 0)
                    : (
                        prefs.preferences.general.tabBarStyle == .xcode
                        ? Color(nsColor: isActive ? .controlAccentColor : .black)
                            .opacity(
                                isPressingClose
                                ? 0.25
                                : (isHoveringClose ? (isActive ? 0.10 : 0.06) : 0)
                            )
                        : Color(nsColor: .black)
                            .opacity(isPressingClose ? 0.29 : (isHoveringClose ? 0.11 : 0))
                    )
                )
                .cornerRadius(2)
                .accessibilityLabel(Text("Close"))
                .onHover { hover in
                    isHoveringClose = hover
                }
                .pressAction {
                    isPressingClose = true
                } onRelease: {
                    isPressingClose = false
                }
                .opacity(isHovering ? 1 : 0)
                .animation(.easeInOut(duration: 0.08), value: isHovering)
                .padding(.leading, prefs.preferences.general.tabBarStyle == .xcode ? 3.5 : 4)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}

fileprivate extension WorkspaceDocument {
    func getTabKeyEquivalent(item: TabBarItemRepresentable) -> KeyEquivalent {
        for counter in 0..<9 where self.selectionState.openFileItems.count > counter &&
        self.selectionState.openFileItems[counter].tabID == item.tabID {
            return KeyEquivalent.init(
                Character.init("\(counter + 1)")
            )
        }
        return "0"
    }
}
