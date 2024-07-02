//
//  GitClientTests.swift
//  Aurora Editor
//
//  Created by Marco Carnevali on 27/03/22.
//  Copyright © 2023 Aurora Company. All rights reserved.
//

import XCTest
@testable import Git
import ShellClient

/// Git client tests
final class GitClientTests: XCTestCase {
    // FIXME: Update GitClient.getCommitHistory implementation on date or this test case
    // Currently this will fail on some non en_US locale like zh_CN

    /// Test history
    func testHistory() throws {
        let shellClient: ShellClient = .always(
            // swiftlint:disable:next line_length
            "e5fe4bf¦e5fe4bf¦Merge pull request #260 from lukepistrol/terminal-color-fix¦Luke¦test@test.com¦Luke¦test@test.com¦Sat, 26 Mar 2022 03:28:12 +0100¦"
        )
        let gitClient: GitClient = .default(
            directoryURL: URL(fileURLWithPath: ""),
            shellClient: shellClient
        )

        guard let fetched = try gitClient.getCommitHistory(nil, nil).first else {
            XCTFail("Failed to get commit history")
        }

        XCTAssertEqual(
            fetched,
            Commit(
                id: fetched.id,
                hash: "e5fe4bf",
                commitHash: "e5fe4bf",
                message: "Merge pull request #1 from test/fixing-bug",
                author: "Person",
                authorEmail: "test@test.com",
                commiter: "Person",
                commiterEmail: "test@test.com",
                remoteURL: nil,
                date: Date(timeIntervalSince1970: 1648261692)
            )
        )
    }
}
