//
//  SearchModeModel.swift
//  Aurora Editor
//
//  Created by Ziyuan Zhao on 2022/3/22.
//  Copyright © 2023 Aurora Company. All rights reserved.
//

import Foundation

/// Search mode Model
@MainActor
public struct SearchModeModel {
    /// Title
    public let title: String

    /// Children
    public let children: [SearchModeModel]

    /// Need selection highlight
    public let needSelectionHightlight: Bool

    /// Containing
    public static let Containing = SearchModeModel(
        title: "Containing",
        children: [],
        needSelectionHightlight: false
    )

    /// Matching word
    public static let MatchingWord = SearchModeModel(
        title: "Matching Word",
        children: [],
        needSelectionHightlight: true
    )

    /// Starts with
    public static let StartingWith = SearchModeModel(
        title: "Starting With",
        children: [],
        needSelectionHightlight: true
    )

    /// Ends with
    public static let EndingWith = SearchModeModel(
        title: "Ending With",
        children: [],
        needSelectionHightlight: true
    )

    /// Text
    public static let Text = SearchModeModel(
        title: "Text",
        children: [.Containing, .MatchingWord, .StartingWith, .EndingWith],
        needSelectionHightlight: false
    )

    /// References
    public static let References = SearchModeModel(
        title: "References",
        children: [.Containing, .MatchingWord, .StartingWith, .EndingWith],
        needSelectionHightlight: true
    )

    /// Definition
    public static let Definitions = SearchModeModel(
        title: "Definitions",
        children: [.Containing, .MatchingWord, .StartingWith, .EndingWith],
        needSelectionHightlight: true
    )

    /// Regular Expression
    public static let RegularExpression = SearchModeModel(
        title: "Regular Expression",
        children: [],
        needSelectionHightlight: true
    )

    /// Call Hierarchy
    public static let CallHierarchy = SearchModeModel(
        title: "Call Hierarchy",
        children: [],
        needSelectionHightlight: true
    )

    /// Find
    public static let Find = SearchModeModel(
        title: "Find",
        children: [.Text, .References, .Definitions, .RegularExpression, .CallHierarchy],
        needSelectionHightlight: false
    )

    /// Replace
    public static let Replace = SearchModeModel(
        title: "Replace",
        children: [.Text, .RegularExpression],
        needSelectionHightlight: true
    )

    /// Text matching modes
    public static let TextMatchingModes: [SearchModeModel] = [
        .Containing,
        .MatchingWord,
        .StartingWith,
        .EndingWith
    ]

    /// Find modes
    public static let FindModes: [SearchModeModel] = [
        .Text,
        .References,
        .Definitions,
        .RegularExpression,
        .CallHierarchy
    ]

    /// Replace modes
    public static let ReplaceModes: [SearchModeModel] = [
        .Text,
        .RegularExpression
    ]

    /// Search modes
    public static let SearchModes: [SearchModeModel] = [
        .Find,
        .Replace
    ]
}

extension SearchModeModel: @preconcurrency Equatable {
    /// Equate
    /// 
    /// - Parameter lhs: left hand side
    /// - Parameter rhs: right hand side
    /// 
    /// - Returns: true if equal
    public static func == (lhs: SearchModeModel, rhs: SearchModeModel) -> Bool {
        lhs.title == rhs.title
            && lhs.children == rhs.children
            && lhs.needSelectionHightlight == rhs.needSelectionHightlight
    }
}
