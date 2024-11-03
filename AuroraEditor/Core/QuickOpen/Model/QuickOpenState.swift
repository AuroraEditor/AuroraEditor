//
//  QuickOpenState.swift
//  Aurora Editor
//
//  Created by Marco Carnevali on 05/04/22.
//  Copyright © 2023 Aurora Company. All rights reserved.
//

import Combine
import Foundation

/// Quick open state
@MainActor
public final class QuickOpenState: ObservableObject {
    /// Open quickly query
    @Published
    var openQuicklyQuery: String = ""

    /// Open quickly files
    @Published
    var openQuicklyFiles: [FileSystemClient.FileItem] = []

    /// Is showing open quickly files
    @Published
    var isShowingOpenQuicklyFiles: Bool = false

    /// File URL
    public let fileURL: URL

    /// Queue
    private let queue = DispatchQueue(label: "com.auroraeditor.quickOpen.searchFiles")

    /// Initialize a new QuickOpenState
    /// 
    /// - Parameter fileURL: file URL
    /// 
    /// - Returns: a new QuickOpenState
    public init(fileURL: URL) {
        self.fileURL = fileURL
    }

    /// Fetch open quickly
    func fetchOpenQuickly() {
        guard !openQuicklyQuery.isEmpty else {
            openQuicklyFiles = []
            self.isShowingOpenQuicklyFiles = !openQuicklyFiles.isEmpty
            return
        }

        queue.async { [weak self] in
            guard let self = self else { return }
            let enumerator = FileManager.default.enumerator(
                at: self.fileURL,
                includingPropertiesForKeys: [
                    .isRegularFileKey
                ],
                options: [
                    .skipsHiddenFiles,
                    .skipsPackageDescendants
                ]
            )
            if let filePaths = enumerator?.allObjects as? [URL] {
                let files = filePaths.filter { url in
                    let state1 = url.lastPathComponent.lowercased().contains(self.openQuicklyQuery.lowercased())
                    do {
                        let values = try url.resourceValues(forKeys: [.isRegularFileKey])
                        return state1 && (values.isRegularFile ?? false)
                    } catch {
                        return false
                    }
                }.map { url in
                    FileSystemClient.FileItem(url: url, children: nil)
                }
                DispatchQueue.main.async {
                    self.openQuicklyFiles = files
                    self.isShowingOpenQuicklyFiles = !self.openQuicklyFiles.isEmpty
                }
            }
        }
    }
}
