//
//  CommitChangesView.swift
//  AuroraEditor
//
//  Created by Nanashi Li on 2022/08/11.
//  Copyright © 2022 Aurora Company. All rights reserved.
//

import SwiftUI

struct CommitChangesView: View {

    private var gitClient: GitClient?

    @State
    private var summaryText: String = ""

    @State
    private var descriptionText: String = ""

    @State
    var workspace: WorkspaceDocument

    init(workspace: WorkspaceDocument) {
        self.workspace = workspace
        self.gitClient = workspace.workspaceClient?.model?.gitClient
    }

    var body: some View {
        VStack(alignment: .leading) {
            Divider()
                .padding(.leading, 5)
                .padding(.horizontal, -15)

            Text("Commit")
                .foregroundColor(.secondary)
                .fontWeight(.semibold)
                .font(.system(size: 11))

            TextField(text: $summaryText) {
                Text(checkIfChangeIsOne() ? getFirstFileSummary() : "Summary (Required)")
            }
            .font(.system(size: 11, weight: .medium))
            .padding(.vertical, 4)
            .padding(.horizontal, 10)
            .textFieldStyle(.plain)
            .background(.ultraThickMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 6))
            .overlay(RoundedRectangle(cornerRadius: 6).stroke(Color.secondary, lineWidth: 0.5).cornerRadius(6))
            .disabled(getFirstFileSummary() == "Unable to commit")

            TextField(text: $descriptionText) {
                Text("Description")
            }
            .font(.system(size: 11, weight: .medium))
            .padding(10)
            .textFieldStyle(.plain)
            .frame(height: 66, alignment: .topLeading)
            .background(.ultraThickMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 6))
            .overlay(RoundedRectangle(cornerRadius: 6).stroke(Color.secondary, lineWidth: 0.5).cornerRadius(6))

            Button {

            } label: {
                Text("Commit to **\(currentGitBranchName())**")
                    .foregroundColor(.white)
                    .font(.system(size: 11))
            }
            .buttonStyle(.borderedProminent)
            .frame(maxWidth: .infinity)
        }
        .padding(10)
    }

    // Based on the Git Change type of the file we create a summary string
    // that matches that of the Git Change type
    private func getFirstFileSummary() -> String {
        let fileName = workspace.workspaceClient?.model?.changed[0].fileName
        switch workspace.workspaceClient?.model?.changed[0].gitStatus {
        case .modified:
            return "Update \(fileName ?? "Unknown File")"
        case .added:
            return "Created \(fileName ?? "Unknown File")"
        case .copied:
            return "Copied \(fileName ?? "Unknown File")"
        case .deleted:
            return "Deleted \(fileName ?? "Unknown File")"
        case .fileTypeChange:
            return "Changed file type \(fileName ?? "Unknown File")"
        case .renamed:
            return "Renamed \(fileName ?? "Unknown File")"
        case .unknown:
            return "Summary (Required)"
        case .updatedUnmerged:
            return "Unmerged file \(fileName ?? "Unknown File")"
        case .ignored:
            return "Ignore file \(fileName ?? "Unknown File")"
        case .unchanged:
            return "Unchanged"
        case .none:
            return "Unable to commit"
        }
    }

    // If there is only one changed file in list we will return true else
    // if there is more than one we return false.
    private func checkIfChangeIsOne() -> Bool {
        return workspace.workspaceClient?.model?.changed.count == 1
    }

    // Gets the current projects branch name.
    private func currentGitBranchName() -> String {
        guard let branchName = try? gitClient?.getCurrentBranchName() else { return "Not Available" }
        return branchName
    }
}

struct CommitChangesView_Previews: PreviewProvider {
    static var previews: some View {
        CommitChangesView(workspace: WorkspaceDocument.init())
    }
}
