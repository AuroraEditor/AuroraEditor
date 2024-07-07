//
//  NotificationsNavigatorToolbarBottom.swift
//  Aurora Editor
//
//  Created by Nanashi Li on 16/09/2023.
//  Copyright © 2023 Aurora Company. All rights reserved.
//

import SwiftUI

/// The bottom toolbar for the notifications navigator.
struct NotificationsNavigatorToolbarBottom: View {

    /// The active state of the control
    @Environment(\.controlActiveState)
    private var activeState

    /// The color scheme
    @Environment(\.colorScheme)
    private var colorScheme

    /// The notifications model
    @ObservedObject
    private var model: NotificationsModel = .shared

    /// The view body.
    var body: some View {
        HStack {
            HStack {
                FilterButton()

                TextField("Filter", text: $model.searchNotifications)
                    .textFieldStyle(.plain)
                    .font(.system(size: 12))

                if !model.searchNotifications.isEmpty {
                    clearFilterButton
                }

                showHistory

                showErrorsOnly
                    .padding(.trailing, 0)
            }
            .padding(.horizontal, 5)
            .padding(.vertical, 3)
            .background(.ultraThinMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 6))
            .overlay(
                RoundedRectangle(cornerRadius: 6)
                    .stroke(Color.gray, lineWidth: 0.5)
                    .clipShape(
                        RoundedRectangle(
                            cornerRadius: 6
                        )
                    )
            )
            .padding(.horizontal, 6)
        }
        .frame(height: 29, alignment: .center)
        .frame(maxWidth: .infinity)
        .overlay(alignment: .top) {
            Divider()
        }
    }

    /// We clear the text and remove the first responder which removes the cursor
    /// when the user clears the filter.
    private var clearFilterButton: some View {
        Button {
            model.searchNotifications = ""
            NSApp.keyWindow?.makeFirstResponder(nil)
        } label: {
            Image(systemName: "xmark.circle.fill")
                .symbolRenderingMode(.hierarchical)
                .accessibilityLabel(Text("Clear filter"))
        }
        .buttonStyle(.plain)
        .opacity(activeState == .inactive ? 0.45 : 1)
    }

    /// Show the history of notifications.
    private var showHistory: some View {
        Button {

        } label: {
            Image(systemName: "clock")
                .font(.system(size: 11))
                .symbolRenderingMode(.hierarchical)
                .accessibilityLabel(Text("History"))
        }
        .buttonStyle(.plain)
        .opacity(activeState == .inactive ? 0.45 : 1)
        .help("Show only issues from open documents and recently built sources")
    }

    /// Show only errors.
    private var showErrorsOnly: some View {
        Button {
            if model.filter == .ERROR {
                model.setFilter(filter: .OFF)
            } else {
                model.setFilter(filter: .ERROR)
            }
        } label: {
            Image(systemName: "exclamationmark.octagon.fill")
                .font(.system(size: 11))
                .symbolRenderingMode(model.filter == .ERROR ? .multicolor : .hierarchical)
                .accessibilityLabel(Text("Errors only"))
        }
        .buttonStyle(.plain)
        .opacity(activeState == .inactive ? 0.45 : 1)
        .help("Show only errors")
    }
}

struct NotificationsNavigatorToolbarBottom_Previews: PreviewProvider {
    static var previews: some View {
        NotificationsNavigatorToolbarBottom()
    }
}
