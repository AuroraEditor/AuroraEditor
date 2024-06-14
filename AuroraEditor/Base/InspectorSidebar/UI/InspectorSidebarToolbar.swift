//
//  InspectorSidebarToolbar.swift
//  Aurora Editor
//
//  Created by Austin Condiff on 3/21/22.
//  Copyright © 2023 Aurora Company. All rights reserved.
//

import SwiftUI

/// The toolbar at the top of the inspector sidebar.
struct InspectorSidebarToolbarTop: View {
    /// The active selection
    @Binding
    private var selection: Int

    /// Targeted
    @State
    var targeted: Bool = true

    /// Icons
    @State
    private var icons = [
        InspectorDockIcon(
            imageName: "doc",
            title: "File Inspector",
            id: 0
        ),
        InspectorDockIcon(
            imageName: "clock",
            title: "History Inspector",
            id: 1
        ),
        InspectorDockIcon(
            imageName: "questionmark.circle",
            title: "Quick Help Inspector",
            id: 2
        )
    ]

    /// Has changed location
    @State
    private var hasChangedLocation: Bool = false

    /// Dragging item
    @State
    private var draggingItem: InspectorDockIcon?

    /// Drug item location
    @State
    private var drugItemLocation: CGPoint?

    /// Initialize with a selection
    /// 
    /// - Parameter selection: the selection
    /// 
    /// - Returns: a new InspectorSidebarToolbarTop instance
    init(selection: Binding<Int>) {
        self._selection = selection
    }

    /// The view body
    var body: some View {
        HStack(spacing: 10) {
            ForEach(icons) { icon in
                makeInspectorIcon(
                    systemImage: icon.imageName,
                    title: icon.title,
                    id: icon.id
                )
                .opacity(draggingItem?.imageName == icon.imageName &&
                         hasChangedLocation &&
                         drugItemLocation != nil ? 0.0 : 1.0)
                .onDrop(of: [.utf8PlainText],
                        delegate: InspectorSidebarDockIconDelegate(
                            item: icon,
                            current: $draggingItem,
                            icons: $icons,
                            hasChangedLocation: $hasChangedLocation,
                            drugItemLocation: $drugItemLocation
                        )
                )
            }
        }
        .frame(height: 29, alignment: .center)
        .frame(maxWidth: .infinity)
        .overlay(alignment: .bottom) {
            Divider()
        }
        .animation(.default, value: icons)
    }

    /// Make an inspector icon
    /// 
    /// - Parameter systemImage: the system image
    /// - Parameter title: the title
    /// - Parameter id: the id
    /// 
    /// - Returns: a new inspector icon
    func makeInspectorIcon(systemImage: String, title: String, id: Int) -> some View {
        Button {
            selection = id
        } label: {
            Image(systemName: systemImage)
                .help(title)
                .symbolVariant(id == selection ? .fill : .none)
                .foregroundColor(id == selection ? .accentColor : .secondary)
                .frame(width: 16, alignment: .center)
                .onDrag {
                    if let index = icons.firstIndex(where: { $0.imageName == systemImage }) {
                        draggingItem = icons[index]
                    }
                    return .init(object: NSString(string: systemImage))
                } preview: {
                    RoundedRectangle(cornerRadius: .zero)
                        .frame(width: .zero)
                }
        }
        .buttonStyle(.plain)
    }

    /// Get image (safe)
    /// 
    /// - Parameter named: the name
    /// - Parameter accesibilityDescription: the accesibility description
    /// 
    /// - Returns: an image
    private func getSafeImage(named: String, accesibilityDescription: String?) -> Image {
        if let nsImage = NSImage(systemSymbolName: named, accessibilityDescription: accesibilityDescription) {
            return Image(nsImage: nsImage)
        } else {
            return Image(symbol: named)
        }
    }

    /// Inspector dock icon
    private struct InspectorDockIcon: Identifiable, Equatable {
        /// The image name
        let imageName: String

        /// The title
        let title: String

        /// The identifier
        var id: Int
    }

    /// Inspector sidebar dock icon delegate
    private struct InspectorSidebarDockIconDelegate: DropDelegate {
        /// The item
        let item: InspectorDockIcon

        /// Current inspector dock icon
        @Binding
        var current: InspectorDockIcon?

        /// Icons
        @Binding
        var icons: [InspectorDockIcon]

        /// Has changed location
        @Binding
        var hasChangedLocation: Bool

        /// Drug item location
        @Binding
        var drugItemLocation: CGPoint?

        /// Drop entered
        /// 
        /// - Parameter info: the drop info
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
                icons.move(fromOffsets: IndexSet(integer: from), toOffset: toIndex > from ? toIndex + 1 : toIndex)
            }
        }

        /// Drop exited
        /// 
        /// - Parameter info: the drop info
        func dropExited(info: DropInfo) {
            drugItemLocation = nil
        }

        /// Drop updated
        /// 
        /// - Parameter info: the drop info
        func dropUpdated(info: DropInfo) -> DropProposal? {
            DropProposal(operation: .move)
        }

        /// Perform drop
        /// 
        /// - Parameter info: the drop info
        func performDrop(info: DropInfo) -> Bool {
            hasChangedLocation = false
            drugItemLocation = nil
            current = nil
            return true
        }
    }
}

struct InspectorSidebarToolbar_Previews: PreviewProvider {
    static var previews: some View {
        InspectorSidebarToolbarTop(selection: .constant(0))
    }
}
