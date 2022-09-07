//
//  QuickOpenState.swift
//  AuroraEditorModules/QuickOpen
//
//  Created by Marco Carnevali on 05/04/22.
//
import Combine
import Foundation

public final class QuickOpenState: ObservableObject {
    @Published var openQuicklyQuery: String = ""
    @Published var openQuicklyFiles: [FileSystemClient.FileItem] = []
    @Published var isShowingOpenQuicklyFiles: Bool = false

    public let fileURL: URL
    private let queue = DispatchQueue(label: "com.auroraeditor.quickOpen.searchFiles")

    public init(fileURL: URL) {
        self.fileURL = fileURL
    }

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
