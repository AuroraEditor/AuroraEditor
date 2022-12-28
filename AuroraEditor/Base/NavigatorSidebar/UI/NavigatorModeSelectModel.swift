//
//  NavigatorModeSelectModel.swift
//  AuroraEditor
//
//  Created by TAY KAI QUAN on 11/9/22.
//  Copyright © 2022 Aurora Company. All rights reserved.
//

import SwiftUI

class NavigatorModeSelectModel: ObservableObject {
    // I am using a static shared instance because the order of navigator mode selectors
    // need to be the same across all top/left sidebars across all windows.
    static let shared: NavigatorModeSelectModel = .init()

    @Published
    var icons: [[SidebarDockIcon]] = [[
        SidebarDockIcon(
            imageName: "folder",
            title: "Project",
            id: 0
        ),
        SidebarDockIcon(
            imageName: "vault",
            title: "Version Control",
            id: 1
        ),
        SidebarDockIcon(
            imageName: "magnifyingglass",
            title: "Search",
            id: 2
        ),
        SidebarDockIcon(
            imageName: "shippingbox",
            title: "Dependencies",
            id: 3
        ),
        SidebarDockIcon(
            imageName: "play",
            title: "Run Application",
            id: 4
        ),
        SidebarDockIcon(
            imageName: "exclamationmark.triangle",
            title: "Warnings and Errors",
            id: 5
        ),
        SidebarDockIcon(
            imageName: "curlybraces.square",
            title: "Hierarchy",
            id: 6
        ),
        SidebarDockIcon(
            imageName: "puzzlepiece.extension",
            title: "Extensions",
            id: 7
        ),
        SidebarDockIcon(
            imageName: "square.grid.2x2",
            title: "Sidebar Items",
            id: 8
        )
    ]]

    @Published
    var hasChangedLocation: Bool = false

    @Published
    var draggingItem: SidebarDockIcon?

    @Published
    var drugItemLocation: CGPoint?

    func makeIcon(named: String, title: String) -> some View {
        getSafeImage(named: named, accesibilityDescription: title)
        .help(title)
        .onDrag {
            if let item = Array(self.icons.joined()).first(where: { $0.imageName == named }) {
                self.draggingItem = item
            }
            return .init(object: NSString(string: named))
        } preview: {
            RoundedRectangle(cornerRadius: .zero)
                .frame(width: .zero)
        }
    }

    private func getSafeImage(named: String, accesibilityDescription: String?) -> Image {
        if let nsImage = NSImage(
            systemSymbolName: named,
            accessibilityDescription: accesibilityDescription
        ) {
            return Image(nsImage: nsImage)
        } else {
            return Image(symbol: named)
        }
    }
}

struct SidebarDockIcon: Identifiable, Equatable {
    let imageName: String
    let title: String
    var id: Int
}

struct NavigatorSidebarDockIconDelegate: DropDelegate {
    let item: SidebarDockIcon
    @Binding var current: SidebarDockIcon?
    @Binding var icons: [SidebarDockIcon]
    @Binding var hasChangedLocation: Bool
    @Binding var drugItemLocation: CGPoint?

    func dropEntered(info: DropInfo) {
        if current == nil {
            current = item
            drugItemLocation = info.location
        }

        guard item != current, let current = current,
                let from = icons.firstIndex(of: current),
                let toIndex = icons.firstIndex(of: item) else { return }

        hasChangedLocation = true
        drugItemLocation = info.location

        if icons[toIndex] != current {
            withAnimation {
                icons.move(
                    fromOffsets: IndexSet(integer: from),
                    toOffset: toIndex > from ? toIndex + 1 : toIndex
                )
            }
        }
    }

    func dropExited(info: DropInfo) {
        drugItemLocation = nil
    }

    func dropUpdated(info: DropInfo) -> DropProposal? {
        DropProposal(operation: .move)
    }

    func performDrop(info: DropInfo) -> Bool {
        hasChangedLocation = false
        drugItemLocation = nil
        current = nil
        return true
    }
}

struct NavigatorToolbarButtonStyle: ButtonStyle {
    var id: Int
    var selection: Int
    var activeState: ControlActiveState
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 12, weight: id == selection ? .semibold : .regular))
            .symbolVariant(id == selection ? .fill : .none)
            .foregroundColor(id == selection ? .accentColor : configuration.isPressed ? .primary : .secondary)
            .frame(width: 25, height: 25, alignment: .center)
            .contentShape(Rectangle())
            .opacity(activeState == .inactive ? 0.45 : 1)
    }
}
