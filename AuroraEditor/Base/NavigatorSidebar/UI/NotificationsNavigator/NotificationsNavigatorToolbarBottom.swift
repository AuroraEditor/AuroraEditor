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

    @State
    var filter: String = ""

    @ObservedObject
    private var model: NotificationsModel = .shared

    var body: some View {
        HStack {
            HStack {
                Image(systemName: "line.3.horizontal.decrease.circle")
                    .foregroundColor(.secondary)
                    .padding(.horizontal, 5)
                TextField("Filter", text: $filter)
                    .textFieldStyle(.plain)
                    .font(.system(size: 12))

                if !filter.isEmpty {
                    clearFilterButton
                        .padding(.trailing, 5)
                }
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
            filter = ""
            NSApp.keyWindow?.makeFirstResponder(nil)
        } label: {
            Image(systemName: "xmark.circle.fill")
                .symbolRenderingMode(.hierarchical)
        }
        .buttonStyle(.plain)
        .opacity(activeState == .inactive ? 0.45 : 1)
    }
}

struct NotificationsNavigatorToolbarBottom_Previews: PreviewProvider {
    static var previews: some View {
        NotificationsNavigatorToolbarBottom()
    }
}
