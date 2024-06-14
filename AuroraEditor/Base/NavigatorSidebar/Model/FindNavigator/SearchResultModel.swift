//
//  SearchResultModel.swift
//  Aurora Editor
//
//  Created by Ziyuan Zhao on 2022/3/22.
//  Copyright © 2023 Aurora Company. All rights reserved.
//

import Foundation

/// A struct for holding information about a file and any matches it may have for a search query.
public class SearchResultModel: Hashable {
    /// Search item model
    public var file: FileSystemClient.FileItem

    /// Line matches
    public var lineMatches: [SearchResultMatchModel]

    /// Initialize a new search result model
    /// 
    /// - Parameter file: file
    /// - Parameter lineMatches: line matches
    /// 
    /// - Returns: a new SearchResultModel
    public init(
        file: FileSystemClient.FileItem,
        lineMatches: [SearchResultMatchModel] = []
    ) {
        self.file = file
        self.lineMatches = lineMatches
    }

    /// Equate
    /// 
    /// - Parameter lhs: left hand side
    /// - Parameter rhs: right hand side
    /// 
    /// - Returns: true if equal
    public static func == (lhs: SearchResultModel, rhs: SearchResultModel) -> Bool {
        return lhs.file == rhs.file
        && lhs.lineMatches == rhs.lineMatches
    }

    /// Hash
    /// 
    /// - Parameter hasher: hasher
    public func hash(into hasher: inout Hasher) {
        hasher.combine(file)
        hasher.combine(lineMatches)
    }
}
