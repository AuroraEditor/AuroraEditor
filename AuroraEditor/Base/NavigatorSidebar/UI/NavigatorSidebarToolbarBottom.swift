//
//  SideBarToolbarBottom.swift
//  Aurora Editor
//
//  Created by Lukas Pistrol on 17.03.22.
//  Copyright © 2023 Aurora Company. All rights reserved.
//

import SwiftUI

/// The bottom toolbar of the navigator sidebar.
struct NavigatorSidebarToolbarBottom: View {

    /// The active state of the control
    @Environment(\.controlActiveState)
    private var activeState

    /// Workspace document
    @EnvironmentObject
    var workspace: WorkspaceDocument

    /// The view body.
    var body: some View {
        HStack(spacing: 10) {
            addNewFileButton
            Spacer()
            sortButton
        }
        .frame(height: 29, alignment: .center)
        .frame(maxWidth: .infinity)
        .padding(.horizontal, 4)
        .overlay(alignment: .top) {
            Divider()
        }
    }

    /// Add new file button.
    private var addNewFileButton: some View {
        Menu {
            Button("Add File") {
                guard let folderURL = workspace.fileSystemClient?.folderURL,
                      let root = try? workspace.fileSystemClient?.getFileItem(folderURL.path) else { return }
                root.addFile(fileName: "untitled") // TODO: use currently selected file instead of root
            }
            Button("Add Folder") {
                guard let folderURL = workspace.fileSystemClient?.folderURL,
                      let root = try? workspace.fileSystemClient?.getFileItem(folderURL.path) else { return }
                // TODO: use currently selected file instead of root
                root.addFolder(folderName: "untitled")
            }
        } label: {
            Image(systemName: "plus")
        }
        .menuStyle(.borderlessButton)
        .menuIndicator(.hidden)
        .frame(maxWidth: 30)
        .opacity(activeState == .inactive ? 0.45 : 1)
    }

    /// Sort button.
    private var sortButton: some View {
        Menu {
            Button {
                workspace.data.sortFoldersOnTop.toggle()
            } label: {
                Text(workspace.data.sortFoldersOnTop ? "Alphabetically" : "Folders on top")
            }
        } label: {
            Image(systemName: "line.3.horizontal.decrease.circle")
        }
        .menuStyle(.borderlessButton)
        .frame(maxWidth: 30)
        .opacity(activeState == .inactive ? 0.45 : 1)
    }
}
