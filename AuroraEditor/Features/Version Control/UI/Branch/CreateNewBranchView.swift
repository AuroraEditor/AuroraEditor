//
//  CreateNewBranchView.swift
//  Aurora Editor
//
//  Created by Nanashi Li on 2022/09/12.
//  Copyright © 2023 Aurora Company. All rights reserved.
//

import SwiftUI
import Version_Control
import OSLog

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

    @State
    private var branchExists: Bool = false

    @EnvironmentObject
    private var versionControl: VersionControlModel

    private let debouncer = Debouncer()

    /// Logger
    let logger = Logger(subsystem: "com.auroraeditor", category: "Create New Branch View")

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
                    .onChange(of: branchName) { newValue in
                        branchExists = branchAlreadyExists(branchName: newValue)
                    }
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

            if branchExists {
                BranchErrorMessageView(
                    isWarning: false,
                    errorMessage: "A branch named **\(branchName)** already exists."
                )
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
                    || branchName.count > 250
                    || branchExists {
                    Button {} label: {
                        Text("Create Branch")
                            .foregroundColor(.gray)
                    }
                    .disabled(true)
                } else {
                    Button {
                        do {
                            // Creates a new branch
                            try Branch().createBranch(directoryURL: workspace.folderURL,
                                                      name: branchName,
                                                      startPoint: revision)

                            // When done creating a new branch we checkout that said new branch
                            try GitCheckout().checkoutBranch(directoryURL: workspace.folderURL,
                                                             account: nil,
                                                             branch: GitBranch(name: branchName,
                                                                               type: .local,
                                                                               ref: ""),
                                                             progressCallback: nil)

                            dismiss()
                        } catch {
                            self.logger.error("Unable to add exisiting remote.")
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

    private func branchAlreadyExists(branchName: String) -> Bool {
        return versionControl.workspaceBranches.contains(where: { $0.name == branchName })
    }
}

struct CreateNewBranchView_Previews: PreviewProvider {
    static var previews: some View {
        CreateNewBranchView(workspace: WorkspaceDocument())
    }
}
