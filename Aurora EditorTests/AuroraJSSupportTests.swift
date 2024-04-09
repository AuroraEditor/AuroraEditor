//
//  AuroraJSSupportTests.swift
//  Aurora Editor
//
//  Created by Wesley de Groot on 09/04/2024.
//  Copyright © 2024 Aurora Company. All rights reserved.
//

import XCTest
@testable import AuroraEditor

final class AuroraJSSupportTests: XCTestCase {
    let jsSupport = JSSupport(workspace: nil)

    func testJSAPIUsingEvaluate() throws {
        guard let value = jsSupport.evaluate(
            script: "AuroraEditor.api('AuroraEditor.api using evaluate...');"
        ), value.toBool() else {
            XCTFail("Error: No value returned.")
            return
        }
    }

    func testJSAPIAPIUsingRespondToApi() {
        guard let value = jsSupport.respondToAE(
            action: "api",
            parameters: ["api": "api using respondToAE()"]
        ), value.toBool() else {
            XCTFail("Error: No value returned.")
            return
        }
    }

    func testJSAPIAPIUsingRespondToCustomApi() {
        guard let script = jsSupport.evaluate(script: "function AEapiTest(v) { return v }"),
              let value = jsSupport.respond(
                action: "AEapiTest",
                parameters: ["val": "api using respond()"]
              ), value.toString() == "api using respond()" else {
            XCTFail("Error: No value returned.")
            return
        }
    }

    func testJSAPIUsingRespondUsingEvaluate() {
        guard let value = jsSupport.evaluate(
            script: "AuroraEditor.respond('func', {'some': 'value', 'dict':'ionary'});"
        ), value.toBool() else {
            XCTFail("Error: No value returned.")
            return
        }
    }

    func testJSAPIWhichShouldFailToReturn() {
        guard let value = jsSupport.evaluate(
            script: "this.should.fail();"
        ), !value.toBool() else {
            XCTFail("Error: value returned.")
            return
        }
    }
}
