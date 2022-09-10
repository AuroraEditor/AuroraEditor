//
//  ProjectCommitHistoryView.swift
//  AuroraEditor
//
//  Created by Nanashi Li on 2022/09/08.
//  Copyright © 2022 Aurora Company. All rights reserved.
//

import SwiftUI

struct ProjectCommitHistoryView: View {

    @ObservedObject
    var projectHistoryModel: ProjectCommitHistory

    @Environment(\.openURL)
    private var openCommit

    @State
    private var selectedSection: Int = 0

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
                        projectHistoryModel.gitHistoryDate = .lastDay
                    case 2:
                        projectHistoryModel.gitHistoryDate = .lastSevenDays
                    case 3:
                        projectHistoryModel.gitHistoryDate = .lastThirtyDays
                    default: // case 0 also falls under this. Just show everything.
                        projectHistoryModel.gitHistoryDate = .none
                    }
                })

                Spacer()

                FilterCommitHistoryView()
                    .frame(width: 300)
            }
            .overlay(alignment: .bottom) {
                Divider()
            }

            switch projectHistoryModel.state {
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

    func commitHistoryList() -> some View {
        List {
            ForEach(projectHistoryModel.projectHistory) { commit in
                CommitHistoryCellView(commit: commit)
                    .contextMenu {
                        Group {
                            Button("Copy Commit Message") {
                                let pasteboard = NSPasteboard.general
                                pasteboard.clearContents()
                                pasteboard.setString(commit.message, forType: .string)
                            }
                            Button("Copy Identifier") {}.disabled(true)
                            Button("Email \(commit.author)...") {
                                let service = NSSharingService(named: NSSharingService.Name.composeEmail)
                                service?.recipients = [commit.authorEmail]
                                service?.perform(withItems: [])
                            }
                        }
                        Divider()
                        Group {
                            Button("Tag \"\(commit.hash)\"...") {}.disabled(true)
                            Button("New Branch from \"\(commit.hash)\"...") {}.disabled(true)
                            Button("Cherry-Pick Tag \"\(commit.hash)\"...") {}.disabled(true)
                        }
                        Divider()
                        Button("View on Host...") {
                            if let commitRemoteURL = commit.commitBaseURL?.absoluteString {
                                let commitURL = "\(commitRemoteURL)/\(commit.commitHash)"
                                openCommit(URL(string: commitURL)!)
                            }
                        }
                        Divider()
                        Button("Switch to \"\(commit.hash)\"...") {}.disabled(true)
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
}
