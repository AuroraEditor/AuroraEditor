//
//  SearchResultFileItem.swift
//  Aurora Editor
//
//  Created by Ziyuan Zhao on 2022/3/22.
//  Copyright © 2023 Aurora Company. All rights reserved.
//

import SwiftUI

/// The search result file item.
struct FindNavigatorResultFileItem: View {

    /// The search state
    @ObservedObject
    private var state: WorkspaceDocument.SearchState

    /// Application preferences model
    @StateObject
    private var prefs: AppPreferencesModel = .shared

    /// The expanded state
    @State
    private var isExpanded: Bool = true

    /// The file item
    private var fileItem: WorkspaceClient.FileItem

    /// The search results
    private var results: [SearchResultModel]

    /// Jump to file closure
    private var jumpToFile: () -> Void

    /// Initialize the search result file item
    /// 
    /// - Parameter state: The search state
    /// - Parameter isExpanded: The expanded state
    /// - Parameter fileItem: The file item
    /// - Parameter results: The search results
    /// - Parameter jumpToFile: The jump to file closure
    /// 
    /// - Returns: A new instance of FindNavigatorResultFileItem
    init(state: WorkspaceDocument.SearchState,
         isExpanded: Bool = true,
         fileItem: WorkspaceClient.FileItem,
         results: [SearchResultModel],
         jumpToFile: @escaping () -> Void) {
             self.state = state
             self.isExpanded = isExpanded
             self.fileItem = fileItem
             self.results = results
             self.jumpToFile = jumpToFile
    }

    /// The found line result
    /// 
    /// - Parameter lineContent: The line content
    /// - Parameter keywordRange: The keyword range
    /// 
    /// - Returns: The found line result
    @ViewBuilder
    private func foundLineResult(_ lineContent: String?, keywordRange: Range<String.Index>?) -> some View {
        if let lineContent = lineContent,
           let keywordRange = keywordRange {
            Text(lineContent[lineContent.startIndex..<keywordRange.lowerBound]) +
            Text(lineContent[keywordRange.lowerBound..<keywordRange.upperBound])
                .foregroundColor(.white)
                .font(.system(size: 12, weight: .bold)) +
            Text(lineContent[keywordRange.upperBound..<lineContent.endIndex])
        }
    }

    /// The view body.
    var body: some View {
        DisclosureGroup(isExpanded: $isExpanded) {
            ForEach(results, id: \.self) { (result: SearchResultModel) in
                HStack(alignment: .top, spacing: 4) {
                    Image(systemName: "text.alignleft")
                        .font(.system(size: 12))
                        .padding(.top, 2)
                    foundLineResult(result.lineContent, keywordRange: result.keywordRange)
                        .lineLimit(prefs.preferences.general.findNavigatorDetail.rawValue)
                        .foregroundColor(Color(nsColor: .secondaryLabelColor))
                        .font(.system(size: 12, weight: .light))
                    Spacer()
                }
            }
        } label: {
            HStack {
                Image(systemName: fileItem.systemImage)
                Text(fileItem.fileName)
                    .foregroundColor(Color(nsColor: NSColor.headerTextColor))
                    .font(.system(size: 13, weight: .semibold)) +
                Text("  ") +
                Text(fileItem.url.path.replacingOccurrences(of: state.workspace.fileURL?.path ?? "", with: ""))
                    .foregroundColor(.secondary)
                    .font(.system(size: 12, weight: .light))
                Spacer()
            }
        }
    }
}
