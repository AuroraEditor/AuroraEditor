//
//  NavigatorSidebarToolbarLeft.swift
//  AuroraEditor
//
//  Created by TAY KAI QUAN on 20/8/22.
//  Copyright © 2022 Aurora Company. All rights reserved.
//

import SwiftUI

struct NavigatorSidebarToolbarLeft: View {
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
        VStack(alignment: .center, spacing: 2) {
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
            Spacer()
        }
        .frame(width: 25, alignment: .center)
        .frame(maxHeight: .infinity)
        .animation(.default, value: model.icons)
    }
}

struct NavigatorSidebarToolbarLeft_Previews: PreviewProvider {
    static var previews: some View {
        NavigatorSidebarToolbarLeft(selection: .constant(0))
    }
}
