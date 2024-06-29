//
//  SearchResultList.swift
//  Aurora Editor
//
//  Created by Ziyuan Zhao on 2022/3/22.
//  Copyright © 2023 Aurora Company. All rights reserved.
//

import SwiftUI

/// The search result list.
struct FindNavigatorResultList: View {

    /// The search state
    @ObservedObject
    private var state: WorkspaceDocument.SearchState

    /// The selected result
    @State
    private var selectedResult: SearchResultModel?

    /// Initialize the search result list
    /// 
    /// - Parameter state: The search state
    /// - Parameter selectedResult: The selected result
    /// 
    /// - Returns: A new instance of FindNavigatorResultList
    init(state: WorkspaceDocument.SearchState, selectedResult: SearchResultModel? = nil) {
        self.state = state
        self.selectedResult = selectedResult
    }

    /// Get the found files
    private var foundFiles: [SearchResultModel] {
        state.searchResult.filter { !$0.hasKeywordInfo }
    }

    /// Get the result with file
    /// 
    /// - Parameter file: The file
    /// 
    /// - Returns: The search result model
    private func getResultWith(_ file: WorkspaceClient.FileItem) -> [SearchResultModel] {
        state.searchResult.filter { $0.file == file && $0.hasKeywordInfo }
    }

    /// The view body.
    var body: some View {
        List(selection: $selectedResult) {
            ForEach(foundFiles, id: \.self) { (foundFile: SearchResultModel) in
                FindNavigatorResultFileItem(
                    state: state,
                    fileItem: foundFile.file, results: getResultWith(foundFile.file)) {
                        state.workspace.openTab(item: foundFile.file)
                }
            }
        }
        .listStyle(.sidebar)
        .onChange(of: selectedResult) { newValue in
            if let file = newValue?.file {
                state.workspace.openTab(item: file)
            }
        }
    }
}
