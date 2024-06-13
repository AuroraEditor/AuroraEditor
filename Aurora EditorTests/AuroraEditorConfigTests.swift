//
//  AuroraEditorConfigTests.swift
//  Aurora Editor Tests
//
//  Created by Wesley de Groot on 10/02/2024.
//  Copyright © 2024 Aurora Company. All rights reserved.
//

import XCTest
@testable import AuroraEditor

/// Aurora Editor Config Tests
final class AuroraEditorConfigTests: XCTestCase {
    /// The configuration
    let cfg = AuroraEditorConfig(fromPath: #file)

    /// Test PHP file
    func testPHPFile() {
        XCTAssertEqual(
            cfg.get(value: .charset, for: "/some/dir/file.php"),
            "utf-8"
        )
    }

    /// Test JavaScript file
    func testJSFile() {
        XCTAssertEqual(
            cfg.get(value: .charset, for: "/some/dir/file.js"),
            "utf-8"
        )
    }

    /// Test JS file in lib dir
    func testJSFileInLibDir() {
        // This should match "lib/**js"
        XCTAssertEqual(
            cfg.get(value: .charset, for: "/lib/someLibrary/file.js"),
            "utf-8"
        )
    }

    /// test wildcard character
    func testWildcardCharacter() {
        XCTExpectFailure("TODO Need to be supported later")

        // This should match "file?.file"
        XCTAssertEqual(
            cfg.get(value: .indent_size, for: "/lib/someLibrary/file1.wcUnitTest"),
            "wcUnitTest"
        )

        XCTAssertEqual(
            cfg.get(value: .indent_size, for: "/lib/someLibrary/file9.wcUnitTest"),
            "wcUnitTest"
        )
    }

    /// test multiple matches
    func testMultipleMatchesNumberic() {
        XCTExpectFailure("TODO Need to be supported later")

        XCTAssertEqual(
            cfg.get(value: .indent_size, for: "/lib/someLibrary/file9.mnUnitTest"),
            "mnUnitTest"
        )
    }
}
