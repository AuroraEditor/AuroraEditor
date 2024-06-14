//
//  NavigatorSidebarToolbar.swift
//  Aurora Editor
//
//  Created by Kai Quan Tay on 28/12/22.
//  Copyright © 2023 Aurora Company. All rights reserved.
//

import SwiftUI

/// The toolbar for the navigator sidebar
struct NavigatorSidebarToolbar: View {

    /// The active state of the control
    @Environment(\.controlActiveState)
    private var activeState

    /// The selection
    @Binding
    private var selection: Int

    /// The toolbar number
    @State
    private var toolbarNumber: Int

    /// The sidebar style
    @Binding
    private var sidebarStyle: AppPreferences.SidebarStyle

    /// Navigator mode select model
    @ObservedObject
    private var model: NavigatorModeSelectModel = .shared

    /// Initialize NavigatorSidebarToolbar
    /// 
    /// - Parameter selection: The selection
    /// - Parameter style: The sidebar style
    /// - Parameter toolbarNumber: The toolbar number
    /// 
    /// - Returns: A new instance of NavigatorSidebarToolbar
    init(selection: Binding<Int>,
         style: Binding<AppPreferences.SidebarStyle>,
         toolbarNumber: Int) {
        self._selection = selection
        self._sidebarStyle = style
        self._toolbarNumber = State(initialValue: toolbarNumber)
    }

    /// The view body.
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

    /// The icons
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
            .focusable(false)
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
