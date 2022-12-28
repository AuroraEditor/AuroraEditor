//
//  NavigatorSidebar+Splitting.swift
//  AuroraEditor
//
//  Created by Kai Quan Tay on 28/12/22.
//  Copyright © 2022 Aurora Company. All rights reserved.
//

import SwiftUI

extension NavigatorSidebar {
    func moveIcon(_ icon: SidebarDockIcon, to position: SplitViewProposalDropPosition) {
        // determine the toolbar that owns the icon
        // and also short circuit if the owner is not 0 or 1, as there should not
        // be any more than two at any given point
        guard let iconOwner = model.icons.firstIndex(where: { icons in
            icons.contains(where: { $0.id == icon.id })
        }), iconOwner >= 0 && iconOwner <= 1 else { return }

        // if the item was dragged to the top from the bottom, move it
        if iconOwner == 0 && position == .bottom {
            moveTopToBottom(icon: icon)
            return
        }

        // if the item was dragged to the bottom from the top, move it
        if iconOwner == 1 && position == .top {
            moveBottomToTop(icon: icon)
        }

        // if the item was dragged from top to top or bottom to bottom, select it
        if (iconOwner == 0 && position == .top) ||
            (iconOwner == 1 && position == .bottom) {
            selections[iconOwner] = icon.id
        }

        // if the item was dragged to the center, combine both toolbars
        if position == .center {
            model.icons = [Array(model.icons.joined())]
            selections = [icon.id]
        }
    }

    func moveTopToBottom(icon: SidebarDockIcon) {
        defer {
            // select a new focus for the top toolbar
            Log.info("Focusing new icon: \(icon.id) \(icon.title)")
            selections[0] = model.icons[0][0].id
        }
        // create the second toolbar if it does not exist
        if selections.count == 1 {
            selections.append(icon.id)
        }

        // remove the icon from its origin
        model.icons[0].removeAll { otherIcon in
            otherIcon.id == icon.id
        }

        // if the model does not have a second row, create it.
        guard model.icons.count == 2 else {
            model.icons.append([icon])
            return
        }

        // else, append the icon to the end of the second row
        model.icons[1].append(icon)
        selections[1] = icon.id

        // trim the top toolbar if its blank
        if model.icons[0].isEmpty {
            model.icons.remove(at: 0)
            selections.remove(at: 0)
        }

        return
    }

    func moveBottomToTop(icon: SidebarDockIcon) {
        // remove the icon from its origin
        model.icons[1].removeAll { otherIcon in
            otherIcon.id == icon.id
        }

        // append the icon to the end of the first row
        model.icons[0].append(icon)
        selections[0] = icon.id

        // trim the bottom toolbar if its blank
        if model.icons[1].isEmpty {
            model.icons.remove(at: 1)
            selections.remove(at: 1)
        } else {
            // select a new focus for the bottom toolbar
            selections[1] = model.icons[1][0].id
        }
    }
}