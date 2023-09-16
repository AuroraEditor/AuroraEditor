//
//  Aurora_Editor_UITests.swift
//  Aurora Editor UITests
//
//  Created by Wesley de Groot on 12/09/2023.
//  Copyright © 2023 Aurora Company. All rights reserved.
//

import XCTest

final class AuroraEditorUITests: XCTestCase {

    override func setUpWithError() throws {
        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testExample() throws {
        // UI tests must launch the application that they test.
        let app = XCUIApplication()
        app.launch()

        // Use XCTAssert and related functions to verify your tests produce the correct results.
        app.terminate()
    }

//    // This test will run the app multiple times, i have no idea how many times.
//    // It bugs on my machine, and never ends.
//    func testLaunchPerformance() throws {
//        if #available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 7.0, *) {
            // This measures how long it takes to launch your application.
//            measure(metrics: [XCTApplicationLaunchMetric()]) {
//                XCUIApplication().launch()
//            }
//        }
//    }
}
