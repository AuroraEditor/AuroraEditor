//
//  RenameBranchView.swift
//  Aurora Editor
//
//  Created by Nanashi Li on 2022/09/10.
//  Copyright © 2023 Aurora Company. All rights reserved.
//

import SwiftUI
import Version_Control
import OSLog

struct RenameBranchView: View {

    @Environment(\.dismiss)
    private var dismiss

    let workspace: WorkspaceDocument

    @State
    var branch: GitBranch

    @State
    var newBranchName: String = "main"

    @EnvironmentObject
    private var versionControl: VersionControlModel

    @State
    private var ruleErrorMessage: String = ""

    @State
    private var ruleErrorTypeIsWarning: Bool = false

    @State
    private var branchExists: Bool = false

    private let debouncer = Debouncer()

    /// Logger
    let logger = Logger(subsystem: "com.auroraeditor", category: "VCS Rename branch view")

    var body: some View {
        VStack(alignment: .leading) {
            Text("Rename branch:")
                .fontWeight(.bold)

            Text("All uncommited changes will be preserved on the renamed branch.")
                .font(.system(size: 11))
                .padding(.vertical, 1)

            HStack {
                Text("From:")
                Text(branch.name)
                    .fontWeight(.medium)
            }
            .padding(.top, 5)

            HStack {
                Text("To:")
                TextField("", text: $newBranchName)
                    .onChange(of: newBranchName) { newValue in
                        branchExists = branchAlreadyExists(branchName: newValue)

                        if branchExists {
                            // We don't want to call the GitHub API every time a change
                            // happens in the text field so we debounce for half a second
                            // to register that the user has stopped typing before making
                            // a call to the API, thus avoiding any rate limits
                            debouncer.debounce(for: 0.5) {
                                RepoBranchRules().checkBranchRules(
                                    branchName: branch.name,
                                    repository: versionControl.repository,
                                    workspaceURL: workspace.folderURL,
                                    ruleErrorMessage: $ruleErrorMessage,
                                    ruleErrorIsWarning: $ruleErrorTypeIsWarning,
                                    versionControl: versionControl
                                )
                            }
                        }
                    }
            }

//            HStack {
//                Image(systemName: "exclamationmark.triangle.fill")
//                    .symbolRenderingMode(.multicolor)
//                    .accessibilityHidden(true)
//                // swiftlint:disable:next line_length
//                Text("This branch is tracking **\"upstream/main\"** and renaming this branch will not change the branch name on the remote.")
//                    .font(.system(size: 11))
//                    .lineLimit(2)
//                    .multilineTextAlignment(.leading)
//            }
//            .padding([.bottom, .top], 5)

            // TODO: This should only show if the user has stashed changes on this branch
            HStack {
                Image(systemName: "exclamationmark.triangle.fill")
                    .symbolRenderingMode(.multicolor)
                    .accessibilityHidden(true)

                // swiftlint:disable:next line_length
                Text("Your current stashed changes on this branch will no longer be visible in Aurora Editor if the branch is renamed.")
                    .font(.system(size: 11))
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)
            }
            .padding([.bottom], 5)

            if !ruleErrorMessage.isEmpty {
                BranchErrorMessageView(
                    isWarning: ruleErrorTypeIsWarning,
                    errorMessage: ruleErrorMessage
                )
            }

            if branchExists {
                BranchErrorMessageView(
                    isWarning: false,
                    errorMessage: "A branch named **\(newBranchName)** already exists."
                )
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

                if branch.name == newBranchName
                    || newBranchName.isEmpty
                    || newBranchName.count < 3
                    || newBranchName.count > 250
                    || branchExists {
                    Button {} label: {
                        Text("Rename")
                            .foregroundColor(.gray)
                    }
                    .disabled(true)
                } else {
                    Button {
                        do {
                            try Branch().renameBranch(directoryURL: workspace.folderURL,
                                                      branch: branch,
                                                      newName: newBranchName)

                            dismiss()
                        } catch {
                            logger.error("Unable to rename current branch.")
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

    private func branchAlreadyExists(branchName: String) -> Bool {
        return versionControl.workspaceBranches.contains(where: { $0.name == branchName })
    }

    @ViewBuilder
    func renderBranchNameExistsOnRemoteWarning(
        sanitizedName: String
    ) -> some View {
        let alreadyExistsOnRemote = versionControl.workspaceBranches.contains { branch in
            branch.nameWithoutRemote == sanitizedName && branch.type == .remote
        }

        if !alreadyExistsOnRemote {
            AnyView(EmptyView())
        }

        BranchErrorMessageView(
            isWarning: true,
            errorMessage: "A branch named **\(sanitizedName)** already exists on the remote."
        )
    }
}
