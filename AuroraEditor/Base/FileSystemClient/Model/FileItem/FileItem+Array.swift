//
//  FileItem+Array.swift
//  Aurora Editor
//
//  Created by Lukas Pistrol on 17.03.22.
//  Copyright © 2023 Aurora Company. All rights reserved.
//
//  This file originates from CodeEdit, https://github.com/CodeEditApp/CodeEdit

import Foundation

public extension Array where Element == FileSystemClient.FileItem {

    /// Sorts the elements in alphabetical order.
    /// - Parameter foldersOnTop: if set to `true` folders will always be on top of files.
    /// - Returns: A sorted array of ``FileSystemClient/FileSystemClient/FileItem``
    func sortItems(foldersOnTop: Bool) -> Self {
        let sortedItems = self.sorted(by: { (item1, item2) in
            return item1.fileName.localizedCompare(item2.fileName) == .orderedAscending
        })

        if foldersOnTop {
            let folders = sortedItems.filter { $0.isFolder }
            let files = sortedItems.filter { !$0.isFolder }
            return folders + files
        } else {
            return sortedItems
        }
    }
}

public extension Array where Element: Hashable {
    /// Finds the symmetric difference between two arrays.
    ///
    /// - Parameter other: The other array.
    /// - Returns: An array containing elements that appear in either `self` or `other`, but not in both.
    func difference(from other: [Element]) -> Set<Element> {
        let thisSet = Set(self)
        let otherSet = Set(other)
        return thisSet.symmetricDifference(otherSet)
    }
}
