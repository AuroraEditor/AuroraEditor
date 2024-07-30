//
//  TabBarItemIcon.swift
//  Aurora Editor
//
//  Created by TAY KAI QUAN on 10/9/22.
//  Copyright © 2023 Aurora Company. All rights reserved.
//

import SwiftUI

extension TabBarItem {
    /// Icon of the tab item
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
        .padding(.horizontal, 23)
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
                }
                .buttonStyle(.borderless)
                .foregroundColor(isPressingClose ? .primary : .secondary)
                .background(
                    colorScheme == .dark
                    ? Color(nsColor: .white)
                        .opacity(isPressingClose ? 0.32 : isHoveringClose ? 0.18 : 0)
                    : (
                        Color(nsColor: isActive ? .controlAccentColor : .black)
                            .opacity(
                                isPressingClose
                                ? 0.25
                                : (isHoveringClose ? (isActive ? 0.10 : 0.06) : 0)
                            )
                    )
                )
                .clipShape(
                    RoundedRectangle(
                        cornerRadius: 2
                    )
                )
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
                .padding(.leading, 3.5)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}

fileprivate extension WorkspaceDocument {
    /// Get the key equivalent for the tab item.
    /// 
    /// - Parameter item: The tab item.
    /// 
    /// - Returns: The key equivalent.
    func getTabKeyEquivalent(item: TabBarItemRepresentable) -> KeyEquivalent {
        for counter in 0..<9 where self.selectionState.openFileItems.count > counter &&
        self.selectionState.openFileItems[counter].tabID == item.tabID {
            return KeyEquivalent(Character("\(counter + 1)")
            )
        }

        return "0"
    }
}
