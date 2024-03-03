//
//  BranchCommitHistoryView.swift
//  Aurora Editor
//
//  Created by Nanashi Li on 2022/09/10.
//  Copyright © 2023 Aurora Company. All rights reserved.
//

import SwiftUI

struct BranchCommitHistoryView: View {
    @ObservedObject
    var branchCommitModel: BranchCommitHistory

    @EnvironmentObject
    var workspace: WorkspaceDocument

    @Environment(\.openURL)
    private var openCommit

    @State
    private var selectedSection: Int = 0

    @State
    private var showInfoPopup: Bool = false

    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                SegmentedControl($selectedSection,
                                 options: ["All", "Last 24 Hours", "Last 7 Days", "Last 30 Days"],
                                 prominent: true)
                .frame(height: 27)
                .padding(.horizontal, 8)
                .padding(.bottom, 2)
                .padding(.top, 1)
                .onChange(of: selectedSection, perform: { _ in
                    switch selectedSection {
                    case 1:
                        branchCommitModel.gitHistoryDate = .lastDay
                    case 2:
                        branchCommitModel.gitHistoryDate = .lastSevenDays
                    case 3:
                        branchCommitModel.gitHistoryDate = .lastThirtyDays
                    default: // case 0 also falls under this. Just show everything.
                        branchCommitModel.gitHistoryDate = .none
                    }
                })

                Spacer()

                switch branchCommitModel.state {
                case .loading:
                    EmptyView()
                case .success:
                    showCommitDetails
                case .error:
                    EmptyView()
                case .empty:
                    EmptyView()
                }

                FilterCommitHistoryView()
                    .frame(width: 300)
            }
            .overlay(alignment: .bottom) {
                Divider()
            }

            switch branchCommitModel.state {
            case .loading:
                loadingChanges
            case .success:
                commitHistoryList()
            case .error:
                errorView
            case .empty:
                emptyView
            }
        }
    }

    private var loadingChanges: some View {
        VStack {
            Text("Loading Changes")
                .font(.system(size: 16))
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private func commitHistoryList() -> some View {
        List {
            ForEach(branchCommitModel.projectHistory) { commit in
                CommitHistoryCellView(commit: commit)
                    .contextMenu {
                        Group {
                            Button {
                                let pasteboard = NSPasteboard.general
                                pasteboard.clearContents()
                                pasteboard.setString(commit.summary, forType: .string)
                            } label: {
                                Text("Copy Commit Message")
                            }
                            Button("Copy Identifier") {}.disabled(true)
                            Button("Email \(commit.author.email)...") {
                                let service = NSSharingService(named: NSSharingService.Name.composeEmail)
                                service?.recipients = [commit.author.email]
                                service?.perform(withItems: [])
                            }
                        }
                        Divider()
                        Group {
                            Button("Tag \"\(commit.sha)\"...") {
                                workspace.data.commitHash = commit.sha
                                workspace.data.showTagCreationSheet.toggle()
                            }
                            Button("New Branch from \"\(commit.sha)\"...") {
                                workspace.data.branchRevision = commit.sha
                                workspace.data.branchRevisionDescription = commit.summary
                                workspace.data.showBranchCreationSheet.toggle()
                            }
                            Button("Cherry-Pick Tag \"\(commit.sha)\"...") {}.disabled(true)
                        }
                        Divider()
                        Button("View on Host...") {
                            //                            if let commitRemoteURL = commit.commitBaseURL?.absoluteString {
                            //                                let commitURL = "\(commitRemoteURL)/\(commit.commitHash)"
                            //                                openCommit(URL(string: commitURL)!)
                            //                            }
                        }
                        Divider()
                        Button("Switch to \"\(commit.sha)\"...") {}.disabled(true)
                    }
            }
        }
        .listStyle(.plain)
    }

    private var errorView: some View {
        VStack {
            Text("Failed To Find Changes")
                .font(.system(size: 16))
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private var emptyView: some View {
        VStack {
            Text("Seems Like There Is No Commits In This \(selectedSection == 0 ? "Project" : "Timeframe")")
                .font(.system(size: 16))
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private var showCommitDetails: some View {
        HStack {
            Button {
                showInfoPopup.toggle()
            } label: {
                Image(systemName: "info.circle")
                    .foregroundColor(.secondary)
            }
            .popover(isPresented: $showInfoPopup) {
                Text("We limit the amount of items that is shown in the commit list to improve performance")
                    .frame(width: 150)
                    .padding()
            }
            .buttonStyle(.plain)

            Text("\(branchCommitModel.projectHistory.count) commits found.")
                .font(.system(size: 11))
                .foregroundColor(.secondary)
        }
        .padding(.horizontal)
    }
}
