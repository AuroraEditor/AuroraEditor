//
//  RenameBranchView.swift
//  AuroraEditor
//
//  Created by Nanashi Li on 2022/09/10.
//  Copyright © 2022 Aurora Company. All rights reserved.
//

import SwiftUI
import Version_Control

struct RenameBranchView: View {

    @Environment(\.dismiss)
    private var dismiss

    let workspace: WorkspaceDocument

    @State
    var currentBranchName: String = "main"

    @State
    var newBranchName: String = "main"

    var body: some View {
        VStack(alignment: .leading) {
            Text("Rename branch:")
                .fontWeight(.bold)

            Text("All uncommited changes will be preserved on the renamed branch.")
                .font(.system(size: 11))
                .padding(.vertical, 1)

            HStack {
                Text("From:")
                Text(currentBranchName)
                    .fontWeight(.medium)
            }
            .padding(.top, 5)

            HStack {
                Text("To:")
                TextField("", text: $newBranchName)
            }

            HStack {
                Image(systemName: "exclamationmark.triangle.fill")
                    .symbolRenderingMode(.multicolor)

                // swiftlint:disable:next line_length
                Text("This branch is tracking **\"upstream/main\"** and renaming this branch will not change the branch name on the remote.")
                    .font(.system(size: 11))
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)
            }
            .padding([.bottom, .top], 5)

            HStack {
                Image(systemName: "exclamationmark.triangle.fill")
                    .symbolRenderingMode(.multicolor)

                // swiftlint:disable:next line_length
                Text("Your current stashed changes on this branch will no longer be visible in Aurora Editor if the branch is renamed.")
                    .font(.system(size: 11))
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)
            }

            HStack {

                if newBranchName.count > 250 {
                    Text("Your new branch name is currently to long")
                        .foregroundColor(.red)
                        .font(.system(size: 11))
                }

                Spacer()

                Button {
                    dismiss()
                } label: {
                    Text("Cancel")
                        .foregroundColor(.primary)
                }

                if currentBranchName == newBranchName
                    || newBranchName.isEmpty
                    || newBranchName.count < 3
                    || newBranchName.count > 250 {
                    Button {} label: {
                        Text("Rename")
                            .foregroundColor(.gray)
                    }
                    .disabled(true)
                } else {
                    Button {
                        do {
                            try renameBranch(directoryURL: workspace.workspaceURL(),
                                             branch: currentBranchName,
                                             newName: newBranchName)
                            dismiss()
                        } catch {
                            Log.error("Unable to rename current branch.")
                        }
                    } label: {
                        Text("Rename")
                            .foregroundColor(.white)
                    }
                    .buttonStyle(.borderedProminent)
                }
            }
            .padding(.top, 10)
        }
        .padding()
        .frame(width: 500, height: 270)
    }
}
