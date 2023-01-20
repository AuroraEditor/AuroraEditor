//
//  FilterCommitHistoryView.swift
//  Aurora Editor
//
//  Created by Nanashi Li on 2022/09/09.
//

import SwiftUI

struct FilterCommitHistoryView: View {

    @Environment(\.controlActiveState)
    private var activeState

    @State
    var filter: String = ""

    var body: some View {
        HStack {
            sortButton
            TextField("Filter", text: $filter)
                .textFieldStyle(.plain)
                .font(.system(size: 12))
            if !filter.isEmpty {
                clearFilterButton
                    .padding(.trailing, 5)
            }
        }
        .padding(.vertical, 3)
        .background(.thickMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 6))
        .overlay(RoundedRectangle(cornerRadius: 6).stroke(Color.gray, lineWidth: 0.5).cornerRadius(6))
        .padding(.trailing, 5)
        .padding(.leading, -8)
    }

    private var sortButton: some View {
        Menu {
            Button {
            } label: {
                Text("Clear Recents")
            }
        } label: {
            Image(systemName: "line.3.horizontal.decrease.circle")
        }
        .menuStyle(.borderlessButton)
        .frame(maxWidth: 30)
        .opacity(activeState == .inactive ? 0.45 : 1)
    }

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

struct FilterCommitHistoryView_Previews: PreviewProvider {
    static var previews: some View {
        FilterCommitHistoryView()
    }
}
