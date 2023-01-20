//
//  NavigatorSidebarToolbar.swift
//  AuroraEditor
//
//  Created by Kai Quan Tay on 28/12/22.
//  Copyright © 2022 Aurora Company. All rights reserved.
//

import SwiftUI

struct NavigatorSidebarToolbar: View {
    @Environment(\.controlActiveState)
    private var activeState

    @Binding
    private var selection: Int

    @State
    private var toolbarNumber: Int

    @Binding
    private var sidebarStyle: AppPreferences.SidebarStyle

    @ObservedObject
    private var model: NavigatorModeSelectModel = .shared

    init(selection: Binding<Int>,
         style: Binding<AppPreferences.SidebarStyle>,
         toolbarNumber: Int) {
        self._selection = selection
        self._sidebarStyle = style
        self._toolbarNumber = State(initialValue: toolbarNumber)
    }

    var body: some View {
        if sidebarStyle == .xcode { // top
            HStack(spacing: 2) {
                Spacer()
                if (0..<model.icons.count).contains(toolbarNumber) {
                    icons
                }
            }
            .frame(height: 29, alignment: .center)
            .frame(maxWidth: .infinity)
            .overlay(alignment: .top) { Divider() }
            .overlay(alignment: .bottom) { Divider() }
        } else { // leading
            VStack(alignment: .center, spacing: 2) {
                if (0..<model.icons.count).contains(toolbarNumber) {
                    icons
                }
            }
            .frame(width: 25, alignment: .center)
            .frame(maxHeight: .infinity)
            .padding(.leading, 5)
            .padding(.trailing, -3)
        }
    }

    @ViewBuilder
    var icons: some View {
        ForEach(model.icons[toolbarNumber]) { icon in
            Button {
                selection = icon.id
            } label: {
                // this icon also serves as the drag and drop item
                model.makeIcon(
                    named: icon.imageName,
                    title: icon.title
                )
            }
            .id(icon.id)
            .buttonStyle(NavigatorToolbarButtonStyle(id: icon.id, selection: selection, activeState: activeState))
            .imageScale(.medium)
            .opacity(model.draggingItem?.imageName == icon.imageName &&
                     model.hasChangedLocation &&
                     model.drugItemLocation != nil ? 0.0 : 1.0)
            .onDrop(
                of: [.utf8PlainText],
                delegate: NavigatorSidebarDockIconDelegate(
                    item: icon,
                    current: $model.draggingItem,
                    icons: $model.icons[toolbarNumber],
                    hasChangedLocation: $model.hasChangedLocation,
                    drugItemLocation: $model.drugItemLocation
                )
            )
        }
        Spacer()
    }
}
