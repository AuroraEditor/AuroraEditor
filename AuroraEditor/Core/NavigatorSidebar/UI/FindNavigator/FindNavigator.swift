//
//  SidebarSearch.swift
//  Aurora Editor
//
//  Created by Ziyuan Zhao on 2022/3/20.
//  Copyright © 2023 Aurora Company. All rights reserved.
//

import SwiftUI

// TODO: Add state management to search @NanashiLi

/// The search bar in the navigator sidebar.
struct FindNavigator: View {

    /// The search state
    @ObservedObject
    private var state: WorkspaceDocument.SearchState

    /// Workspace document
    @EnvironmentObject
    private var workspace: WorkspaceDocument

    /// The search text
    @State
    private var searchText: String = ""

    /// The filters
    enum Filters: String {

        /// Ignoring case
        case ignoring = "Ignoring Case"

        /// Matching case
        case matching = "Matching Case"
    }

    /// The current filter
    @State
    var currentFilter: String = ""

    /// The submitted text
    @State
    private var submittedText: Bool = false

    /// The found files count
    private var foundFilesCount: Int {
        state.searchResult.count
    }

    /// The found results count
    private var foundResultsCount: Int {
        state.searchResult.count
    }

    /// Initialize the find navigator
    /// 
    /// - Parameter state: The search state
    init(state: WorkspaceDocument.SearchState) {
        self.state = state
    }

    /// The view body.
    var body: some View {
        VStack {
            VStack {
                FindNavigatorModeSelector(state: state)
                FindNavigatorSearchBar(state: state,
                                       text: $searchText,
                                       submittedText: $submittedText)
                HStack {
                    Button {} label: {
                        Text("In Workspace")
                            .font(.system(size: 10))
                    }.buttonStyle(.borderless)
                    Spacer()
                    Menu {
                        Button {
                            currentFilter = Filters.ignoring.rawValue
                            state.ignoreCase = true
                            state.search(searchText)
                        } label: {
                            Text(Filters.ignoring.rawValue)
                                .font(.system(size: 11))
                        }
                        Button {
                            currentFilter = Filters.matching.rawValue
                            state.ignoreCase = false
                            state.search(searchText)
                        } label: {
                            Text(Filters.matching.rawValue)
                                .font(.system(size: 11))
                        }
                    } label: {
                        HStack(spacing: 2) {
                            Spacer()
                            Text(currentFilter)
                                .foregroundColor(currentFilter == Filters.matching.rawValue ?
                                                 Color.accentColor : .primary)
                                .font(.system(size: 10))
                        }
                    }
                    .font(.system(size: 10))
                    .menuStyle(.borderlessButton)
                    .frame(width: currentFilter == Filters.ignoring.rawValue ? 80 : 88)
                    .onAppear {
                        if currentFilter.isEmpty {
                            currentFilter = Filters.ignoring.rawValue
                        }
                    }
                }
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 5)
            Divider()
            if !searchText.isEmpty && submittedText {
                VStack {
                    HStack(alignment: .center) {
                        Text(
                            "\(state.searchResultCount) results in \(foundFilesCount) files")
                        .font(.system(size: 10))
                    }
                    Divider()
                        .padding(.top, -5)
                }
                .padding(.bottom, -12)
            }
            if !searchText.isEmpty && foundFilesCount <= 0 && submittedText {
                VStack(alignment: .center) {
                    Text("No Results for \n\"\(searchText)\"\n in project")
                        .multilineTextAlignment(.center)
                        .font(.system(size: 16))
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else if !searchText.isEmpty && submittedText {
                FindNavigatorResultList()
            }
        }
        .frame(maxHeight: .infinity, alignment: .top)
        .onSubmit {
            submittedText = true
            state.search(searchText)
        }
    }
}
