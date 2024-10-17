//
//  NavigatorModeSelectModel.swift
//  Aurora Editor
//
//  Created by TAY KAI QUAN on 11/9/22.
//  Copyright © 2023 Aurora Company. All rights reserved.
//

import SwiftUI

/// The model for the navigator mode selector.
@MainActor
class NavigatorModeSelectModel: ObservableObject {
    /// Shared instance.
    static let shared: NavigatorModeSelectModel = .init()

    /// A 2D array of ``SidebarDockIcon``s. Each subarray is a different pane.
    /// Currently, it is hard-coded to not work with more than 2 panes.
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

    /// Has changed location.
    @Published
    var hasChangedLocation: Bool = false

    /// The dragging item.
    @Published
    var draggingItem: SidebarDockIcon?

    /// Drugged item location.
    @Published
    var drugItemLocation: CGPoint?

    /// Make an icon.
    /// 
    /// - Parameter named: The name of the icon.
    /// - Parameter title: The title of the icon.
    /// 
    /// - Returns: The icon.
    func makeIcon(named: String, title: String) -> some View {
        getSafeImage(named: named, accesibilityDescription: title)
        .help(title)
        .onDrag {
            if let item = Array(self.icons.joined()).first(where: { $0.imageName == named }) {
                self.draggingItem = item
            }
            return .init(object: NSString(string: named))
        } preview: {
            getSafeImage(named: named, accesibilityDescription: title)
        }
    }

    /// Get a image (safe).
    /// 
    /// - Parameter named: The name of the image.
    /// - Parameter accesibilityDescription: The accesibility description.
    /// 
    /// - Returns: The image.
    private func getSafeImage(named: String, accesibilityDescription: String?) -> some View {
        if let nsImage = NSImage(
            systemSymbolName: named,
            accessibilityDescription: accesibilityDescription
        ) {
            return Image(nsImage: nsImage)
                .accessibilityLabel(Text("\(accesibilityDescription ?? ""))"))
        } else {
            return Image(symbol: named)
                .accessibilityLabel(Text("\(accesibilityDescription ?? ""))"))
        }
    }
}

/// A sidebar dock icon.
struct SidebarDockIcon: Identifiable, Equatable {

    /// The name of the image.
    let imageName: String

    /// The title of the icon.
    let title: String

    /// The id of the icon.
    var id: Int
}

/// A navigator sidebar dock icon delegate.
struct NavigatorSidebarDockIconDelegate: DropDelegate {

    /// The item.
    let item: SidebarDockIcon

    /// The current item.
    @Binding
    var current: SidebarDockIcon?

    /// The icons.
    @Binding
    var icons: [SidebarDockIcon]

    /// Has changed location.
    @Binding
    var hasChangedLocation: Bool

    /// The drug item location.
    @Binding
    var drugItemLocation: CGPoint?

    /// Drop entered.
    /// 
    /// - Parameter info: The drop info.
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

    /// Drop exited.
    /// 
    /// - Parameter info: The drop info.
    func dropExited(info: DropInfo) {
        drugItemLocation = nil
    }

    /// Drop updated.
    /// 
    /// - Parameter info: The drop info.
    /// 
    /// - Returns: The drop proposal.
    func dropUpdated(info: DropInfo) -> DropProposal? {
        DropProposal(operation: .move)
    }

    /// Perform drop.
    /// 
    /// - Parameter info: The drop info.
    /// 
    /// - Returns: A boolean indicating if the drop was successful.
    func performDrop(info: DropInfo) -> Bool {
        hasChangedLocation = false
        drugItemLocation = nil
        current = nil
        return true
    }
}

/// A navigator toolbar button style.
struct NavigatorToolbarButtonStyle: ButtonStyle {

    /// The id of the button.
    var id: Int

    /// The selection.
    var selection: Int

    /// The active state.
    var activeState: ControlActiveState

    /// Make the body.
    /// 
    /// - Parameter configuration: The configuration.
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
