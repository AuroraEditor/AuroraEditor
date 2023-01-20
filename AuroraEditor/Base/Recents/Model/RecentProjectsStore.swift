//
//  RecentProjectsStore.swift
//  Aurora Editor
//
//  Created by ladvoc on 2022/12/01.
//  Copyright © 2023 Aurora Company. All rights reserved.
//

import Combine
import Foundation

/// Persistent store for recent project paths.
@MainActor
public final class RecentProjectsStore: ObservableObject {

    /// The publicly available singleton instance of ``RecentProjectsStore``
    public static let shared: RecentProjectsStore = .init()

    private var autoRemoveTask: Task<Void, Error>?

    private init() {
        self.paths = load()
        autoRemove()
    }

    /// Array of recent paths with the most recent at index zero.
    @Published
    public private(set) var paths = [String]() {
        didSet { save() }
    }

    /// Record the given path as a recent.
    /// - Note: if the given path does not exist in the filesystem, it is ignored.
    public func record(path: String) {
        guard let existingIndex = paths.firstIndex(of: path) else {
            guard FileManager.default.fileExists(atPath: path) else { return }
            paths.insert(path, at: 0)
            return
        }
        paths.move(
            fromOffsets: IndexSet(integer: existingIndex),
            toOffset: 0
        )
    }

    /// Remove the given path if it exists in the store.
    public func remove(path: String) {
        guard let pathIndex = paths.firstIndex(of: path) else { return }
        paths.remove(at: pathIndex)
    }

    /// Clear all recent paths.
    public func clearAll() {
        paths = []
    }

    /// Load recent paths from user defaults.
    private func load() -> [String] {
        guard let paths = UserDefaults.standard.array(forKey: Self.key) as? [String] else {
            return []
        }
        return paths
    }

    /// Persist recent paths to user defaults.
    private func save() {
        UserDefaults.standard.set(self.paths, forKey: Self.key)
    }

    /// Automatically remove paths which no longer exist in the filesystem.
    private func autoRemove() {
        autoRemoveTask = Task(priority: .utility) {
            while !Task.isCancelled {
                paths = paths
                    .filter { FileManager.default.fileExists(atPath: $0) }
                try await Task.sleep(nanoseconds: Self.autoRemoveDuration)
            }
        }
    }

    deinit {
        autoRemoveTask?.cancel()
    }

    /// How often to perform an auto-remove.
    private static let autoRemoveDuration: UInt64 = 10_000 * 1_000_000

    /// User defaults key for persistence.
    private static let key = "recentProjectPaths"
}
