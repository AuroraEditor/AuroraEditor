//
//  NotificationsNavigatorToolbarBottom.swift
//  Aurora Editor
//
//  Created by Nanashi Li on 03/02/2023.
//  Copyright © 2023 Aurora Company. All rights reserved.
//

import SwiftUI

struct NotificationsNavigatorToolbarBottom: View {
    @Environment(\.controlActiveState)
    private var activeState

    @Environment(\.colorScheme)
    private var colorScheme

    @ObservedObject
    private var model: NotificationsModel = .shared

    var body: some View {
        HStack {
            HStack {
                Image(systemName: "line.3.horizontal.decrease.circle")
                    .foregroundColor(.secondary)
                    .padding(.horizontal, 5)
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
            .overlay(RoundedRectangle(cornerRadius: 6).stroke(Color.gray, lineWidth: 0.5).cornerRadius(6))
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
        }
        .buttonStyle(.plain)
        .opacity(activeState == .inactive ? 0.45 : 1)
    }

    private var showHistory: some View {
        Button {

        } label: {
            Image(systemName: "clock")
                .font(.system(size: 11))
                .symbolRenderingMode(.hierarchical)
        }
        .buttonStyle(.plain)
        .opacity(activeState == .inactive ? 0.45 : 1)
        .help("Show only issues from open documents and recently built sources")
    }

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
