//
//  SideBarToolbar.swift
//  AuroraEditor
//
//  Created by Lukas Pistrol on 17.03.22.
//

import SwiftUI

struct NavigatorSidebarToolbarTop: View {
    @Environment(\.controlActiveState)
    private var activeState

    @Binding
    private var selection: Int

    @ObservedObject
    private var model: NavigatorModeSelectModel = .shared

    init(selection: Binding<Int>) {
        self._selection = selection
    }

    var body: some View {
        HStack(spacing: 2) {
            ForEach(model.icons) { icon in
                Button {
                    selection = icon.id
                } label: {
                    model.makeIcon(
                        named: icon.imageName,
                        title: icon.title
                    )
                }
                .buttonStyle(NavigatorToolbarButtonStyle(id: icon.id, selection: selection, activeState: activeState))
                .imageScale(.medium)
                .opacity(model.draggingItem?.imageName == icon.imageName &&
                         model.hasChangedLocation &&
                         model.drugItemLocation != nil ? 0.0: 1.0)
                .onDrop(
                    of: [.utf8PlainText],
                        delegate: NavigatorSidebarDockIconDelegate(
                            item: icon,
                            current: $model.draggingItem,
                            icons: $model.icons,
                            hasChangedLocation: $model.hasChangedLocation,
                            drugItemLocation: $model.drugItemLocation
                        )
                )
            }
        }
        .frame(height: 29, alignment: .center)
        .frame(maxWidth: .infinity)
        .overlay(alignment: .top) {
            Divider()
        }
        .overlay(alignment: .bottom) {
            Divider()
        }
        .animation(.default, value: model.icons)
    }
}

struct NavigatorSidebarToolbar_Previews: PreviewProvider {
    static var previews: some View {
        NavigatorSidebarToolbarTop(selection: .constant(0))
    }
}
