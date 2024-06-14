//
//  UnitTests.swift
//  Aurora Editor
//
//  Created by Ziyuan Zhao on 2022/3/19.
//  Copyright © 2023 Aurora Company. All rights reserved.
//

@testable import WelcomeModule
import ShellClient
import Git
import Foundation
import SnapshotTesting
import SwiftUI
import XCTest

/// Unit tests for the Welcome module.
final class WelcomeModuleUnitTests: XCTestCase {

    /// Whether to record snapshots.
    let record: Bool = false

    /// Test recent project item light snapshot.
    func testRecentProjectItemLightSnapshot() throws {
        let view = RecentProjectItem(projectPath: "Project Path")
            .preferredColorScheme(.light)
        let hosting = NSHostingView(rootView: view)
        hosting.appearance = .init(named: .aqua)
        hosting.frame = CGRect(x: 0, y: 0, width: 300, height: 60)
        assertSnapshot(matching: hosting, as: .image, record: record)
    }

    /// Test recent project item dark snapshot.
    func testRecentProjectItemDarkSnapshot() throws {
        let view = RecentProjectItem(projectPath: "Project Path")
            .preferredColorScheme(.dark)
        let hosting = NSHostingView(rootView: view)
        hosting.appearance = .init(named: .darkAqua)
        hosting.frame = CGRect(x: 0, y: 0, width: 300, height: 60)
        assertSnapshot(matching: hosting, as: .image, record: record)
    }

    /// Test recent js project item light snapshot.
    func testRecentJSFileLightSnapshot() throws {
        let view = RecentProjectItem(projectPath: "Project Path/test.js")
            .preferredColorScheme(.light)
        let hosting = NSHostingView(rootView: view)
        hosting.appearance = .init(named: .aqua)
        hosting.frame = CGRect(x: 0, y: 0, width: 300, height: 60)
        assertSnapshot(matching: hosting, as: .image, record: record)
    }

    /// Test recent js project item dark snapshot.
    func testRecentJSFileDarkSnapshot() throws {
        let view = RecentProjectItem(projectPath: "Project Path/test.js")
            .preferredColorScheme(.dark)
        let hosting = NSHostingView(rootView: view)
        hosting.appearance = .init(named: .darkAqua)
        hosting.frame = CGRect(x: 0, y: 0, width: 300, height: 60)
        assertSnapshot(matching: hosting, as: .image, record: record)
    }

    /// Test welcome action view light snapshot.
    func testWelcomeActionViewLightSnapshot() throws {
        let view = WelcomeActionView(
            iconName: "plus.square",
            title: "Create a new file",
            subtitle: "Create a new file"
        ).preferredColorScheme(.light)
        let hosting = NSHostingView(rootView: view)
        hosting.appearance = .init(named: .aqua)
        hosting.frame = CGRect(x: 0, y: 0, width: 300, height: 60)
        assertSnapshot(matching: hosting, as: .image, record: record)
    }

    /// Test welcome action view dark snapshot.
    func testWelcomeActionViewDarkSnapshot() throws {
        let view = WelcomeActionView(
            iconName: "plus.square",
            title: "Create a new file",
            subtitle: "Create a new file"
        ).preferredColorScheme(.dark)
        let hosting = NSHostingView(rootView: view)
        hosting.appearance = .init(named: .darkAqua)
        hosting.frame = CGRect(x: 0, y: 0, width: 300, height: 60)
        assertSnapshot(matching: hosting, as: .image, record: record)
    }
}
