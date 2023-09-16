//
//  AuroraINITests.swift
//  Aurora Editor Tests
//
//  Created by Wesley de Groot on 05/07/2022.
//  Copyright © 2023 Aurora Company. All rights reserved.
//

import XCTest
@testable import AuroraEditor

final class AuroraINITests: XCTestCase {
    func testINIParser() throws {
        let iniFile = """
; Old school comment
# Newer comment
root = true

[mySection]
myValue="Some long string"
short=short
"""
        XCTAssertEqual(
            AuroraINIParser(ini: iniFile).parse(),
            [
                "main": ["root": "true"],
                "mySection": [
                        "myValue": "Some long string",
                        "short": "short"
                ]
            ]
        )
    }
}
