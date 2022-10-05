//
//  CreateNewBranchView.swift
//  AuroraEditor
//
//  Created by Nanashi Li on 2022/09/12.
//  Copyright © 2022 Aurora Company. All rights reserved.
//

import SwiftUI
import Version_Control

struct CreateNewBranchView: View {
    @Environment(\.dismiss)
    private var dismiss

    let workspace: WorkspaceDocument

    @State
    var revision: String = ""

    @State
    var revisionDesciption: String = ""

    @State
    var branchName: String = ""

    var body: some View {
        VStack(alignment: .leading) {
            Text("Create a new branch:")
                .fontWeight(.bold)

            HStack {
                Text("From:")
                Text(revision)
                    .fontWeight(.medium)
            }
            .padding(.top, 5)

            HStack {
                Text("To:")
                TextField("", text: $branchName)
            }

            if !revisionDesciption.isEmpty {
                // swiftlint:disable:next line_length
                Text("Your new branch will be based on a commit \"**\(revisionDesciption)**\" (\(revision)) from your repository.")
                    .font(.system(size: 11))
                    .lineLimit(3)
                    .multilineTextAlignment(.leading)
                    .padding(.top, 5)
            } else if !revision.isEmpty {
                Text("Your new branch will be based on your currently selected branch \"**\(revision)**\".")
                    .font(.system(size: 11))
                    .lineLimit(3)
                    .multilineTextAlignment(.leading)
                    .padding(.top, 5)
            } else {
                Text("Your new branch will be based on your currently checked out branch \"**\(revision)**\".")
                    .font(.system(size: 11))
                    .lineLimit(3)
                    .multilineTextAlignment(.leading)
                    .padding(.top, 5)
            }

            HStack {
                Spacer()

                Button {
                    dismiss()
                } label: {
                    Text("Cancel")
                        .foregroundColor(.primary)
                }

                if branchName.isEmpty
                    || branchName.count < 3
                    || branchName.count > 250 {
                    Button {} label: {
                        Text("Create Branch")
                            .foregroundColor(.gray)
                    }
                    .disabled(true)
                } else {
                    Button {
                        do {
                            // Creates a new branch
                            try createBranch(directoryURL: workspace.workspaceURL(),
                                             name: branchName,
                                             startPoint: revision,
                                             noTrack: nil)

                            // When done creating a new branch we checkout that said new branch
                            try checkoutBranch(directoryURL: workspace.workspaceURL(),
                                               branch: branchName)

                            dismiss()
                        } catch {
                            Log.error("Unable to add exisiting remote.")
                        }
                    } label: {
                        Text("Create Branch")
                            .foregroundColor(.white)
                    }
                    .buttonStyle(.borderedProminent)
                }
            }
            .padding(.top, 10)
        }
        .padding()
        .frame(width: 500, height: 190)
    }
}

struct CreateNewBranchView_Previews: PreviewProvider {
    static var previews: some View {
        CreateNewBranchView(workspace: WorkspaceDocument())
    }
}
