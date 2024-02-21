//
//  AuroraEditorConfigTests.swift
//  Aurora Editor Tests
//
//  Created by Wesley de Groot on 10/02/2024.
//  Copyright © 2024 Aurora Company. All rights reserved.
//

import XCTest
@testable import AuroraEditor

final class AuroraEditorConfigTests: XCTestCase {
    let cfg = AuroraEditorConfig(fromPath: #file)

    func testPHPFile() {
        XCTAssertEqual(
            cfg.get(value: .charset, for: "/some/dir/file.php"),
            "utf-8"
        )
    }

    func testJSFile() {
        XCTAssertEqual(
            cfg.get(value: .charset, for: "/some/dir/file.js"),
            "utf-8"
        )
    }

    func testJSFileInLibDir() {
        // This should match "lib/**js"
        XCTAssertEqual(
            cfg.get(value: .charset, for: "/lib/someLibrary/file.js"),
            "utf-8"
        )
    }

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

    func testMultipleMatchesNumberic() {
        XCTExpectFailure("TODO Need to be supported later")

        XCTAssertEqual(
            cfg.get(value: .indent_size, for: "/lib/someLibrary/file9.mnUnitTest"),
            "mnUnitTest"
        )
    }
}
