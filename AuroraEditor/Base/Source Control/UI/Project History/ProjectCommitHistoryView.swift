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

    @State
    private var selectedSection: Int = 0

    @State
    private var gitHistoryCount: Int = 0

    var body: some View {
        VStack(alignment: .leading) {
            SegmentedControl($selectedSection,
                             options: ["All", "Last 24 Hours", "Last 7 Days", "Last 30 Days"],
                             prominent: true)
            .frame(maxWidth: .infinity)
            .frame(height: 27)
            .padding(.horizontal, 8)
            .padding(.bottom, 2)
            .padding(.top, 1)
            .overlay(alignment: .bottom) {
                Divider()
            }

            switch selectedSection {
            case 0:
                debug("Selected All")
                commitHistoryList(historyItems: 1998)
            case 1:
                debug("Selected Last 24 Hours")
                commitHistoryList(historyItems: 24)
            case 2:
                debug("Selected Last 7 Days")
                commitHistoryList(historyItems: 65)
            case 3:
                debug("Selected Last 30 Days")
                commitHistoryList(historyItems: 220)
            default:
                debug("Selected All")
            }
        }
    }

    func commitHistoryList(historyItems: Int) -> some View {
        List {
            ForEach(projectHistoryModel.projectHistory) { _ in
                CommitHistoryCellView()
                    .contextMenu {
                        Group {
                            Button("Copy Commit Message") {}
                            Button("Copy Identifier") {}
                            Button("Email Nanashi Li...") {}
                        }
                        Divider()
                        Group {
                            Button("Tag \"e038595\"...") {}
                            Button("New Branch from \"e038595\"...") {}
                            Button("Cherry-Pick Tag \"e038595\"...") {}
                        }
                        Divider()
                        Button("View on Host...") {}
                        Divider()
                        Button("Switch to \"e038595\"...") {}
                    }
            }
        }
        .listStyle(.plain)
    }
}
