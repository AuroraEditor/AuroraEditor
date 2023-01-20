//
//  FileItem+Array.swift
//  Aurora Editor
//
//  Created by Lukas Pistrol on 17.03.22.
//  Copyright © 2023 Aurora Company. All rights reserved.
//

import Foundation

public extension Array where Element == FileSystemClient.FileItem {

    /// Sorts the elements in alphabetical order.
    /// - Parameter foldersOnTop: if set to `true` folders will always be on top of files.
    /// - Returns: A sorted array of ``FileSystemClient/FileSystemClient/FileItem``
    func sortItems(foldersOnTop: Bool) -> Self {
        var alphabetically = sorted { $0.fileName < $1.fileName }

        if foldersOnTop {
            var foldersOnTop = alphabetically.filter { $0.children != nil }
            alphabetically.removeAll { $0.children != nil }

            foldersOnTop.append(contentsOf: alphabetically)

            return foldersOnTop
        } else {
            return alphabetically
        }
    }
}

public extension Array where Element: Hashable {
    /// Checks the difference between two given items.
    /// - Parameter other: Other element
    /// - Returns: symmetricDifference
    func difference(from other: [Element]) -> [Element] {
        let thisSet = Set(self)
        let otherSet = Set(other)
        return Array(thisSet.symmetricDifference(otherSet))
    }
}
