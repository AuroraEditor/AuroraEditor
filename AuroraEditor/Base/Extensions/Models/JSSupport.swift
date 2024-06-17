//
//  JSSupport.swift
//  Aurora Editor
//
//  Created by Wesley de Groot on 09/04/2024.
//  Copyright © 2024 Aurora Company. All rights reserved.
//

import Foundation
import JavaScriptCore
import OSLog
import AEExtensionKit
import SwiftUI

/// This class is used to support JavaScript extensions in AuroraEditor.
/// This class has no static function since we need to run a new instance for every extension.
class JSSupport: ExtensionInterface {
    /// Create the os_log logger
    var jsLogger: Logger

    /// The current JavaScript context where we are running in
    var context = JSContext()!

    /// Responder (typealias because of cleaner code)
    typealias Responder = @convention (block) (String, [String: Any]) -> Any

    /// Create a function which returns "AEContext", it should be start witht the semicolon because we
    /// do not know if the last line of the extension is a newline.
    /// if the result of the total evaluation is "AEContext", the extension did load correctly,
    /// if the result is any other than that then either the extension developer has a early return,
    /// or a syntax error.
    let aeContextDidLoad = ";function AEContext() { return \"AEContext\" };"

    /// Extension name.
    var extensionName = ""

    /// Save the current Workspace Document
    var workspace: WorkspaceDocument?

    /// Initialize
    /// - Parameter workspace: workspace document
    init?(name: String, path: String, workspace: WorkspaceDocument?) {
        // Set the extension name
        self.extensionName = name

        // Set the workspace name
        self.workspace = workspace

        // Initialize jsLogger to use the extension name as category.
        jsLogger = Logger(
            subsystem: "com.auroraeditor.JSSupport",
            category: name
        )

        // Register JS Functions
        registerJS()

        // Load the JS Extension, do NEVER return nil if we are running tests.
        if !loadJSExtension(path: path) && name != "AEXCTestCase" {
            return nil
        }
    }

    /// Register JS Extension
    /// - Parameter script: extension path
    public func loadJSExtension(path: String) -> Bool {
        do {
            // Read the contents of the file
            let content = try String(contentsOfFile: path)

            // Evaluate the script
            context.evaluateScript(aeContextDidLoad + content)

            // Check if the extension has loaded correctly
            if let result = context.objectForKeyedSubscript("AEContext").call(withArguments: nil),
               // If the value is not AEContext, it has failed to load
               // See `aeContextDidLoad` fore more information.
                result.toString() != "AEContext" {
                jsLogger.error("Extension \"\(self.extensionName)\" failed to load.")
                return false
            }
        } catch {
            jsLogger.error(
                "Could not read the contents of \"\(self.extensionName)\" (extension.js), Error: \(error)"
            )

            return false
        }

        return true
    }

    /// Register JS Functions
    func registerJS() {
        registerErrorHandler()
        registerScripts()
        registerFunctions()
    }

    /// Register the exception handler for JS.
    /// We should show this for extension developers, so they can use
    /// `Console.app` to view JS Errors, use `com.auroraeditor.JSSupport` as subsystem
    /// and the category is your extension name.
    func registerErrorHandler() {
        context.exceptionHandler = { _, exception in
            self.jsLogger.error("JS Error: \(exception?.description ?? "Unknown error")")
        }
    }

    /// Register the required functions for the JS API.
    func registerFunctions() {
        let log: @convention (block) (String) -> Bool = { (message: String) in
            self.jsLogger.debug("JSAPI Message: \(message)")

            return true
        }

        let respond: Responder = { (action: String, parameters: [String: Any])  in
            self.jsLogger.debug(
                "JSAPI:\n Function: \(action)\n Parameters: \(String(describing: parameters))"
            )

            // Broadcast the action to Aurora Editor
            self.workspace?.broadcaster.broadcast(
                sender: self.extensionName,
                command: action,
                parameters: parameters
            )

            return true
        }

        // Create AuroraEditor.log(...)
        context
            .objectForKeyedSubscript("AuroraEditor")
            .setObject(
                unsafeBitCast(log, to: AnyObject.self),
                forKeyedSubscript: "log" as (NSCopying & NSObjectProtocol)
            )

        // Create AuroraEditor.respond(...)
        context
            .objectForKeyedSubscript("AuroraEditor")
            .setObject(
                unsafeBitCast(respond, to: AnyObject.self),
                forKeyedSubscript: "respond" as (NSCopying & NSObjectProtocol)
            )
    }

    /// Register the required AuroraEditor class.
    func registerScripts() {
        // Make sure AuroraEditor is defined.
        // This script will be filled with aliases and more.
        context
            .evaluateScript("var AuroraEditor = {};")

        JSTimerSupport.shared.registerInto(jsContext: context)
        JSPromise.shared.registerInto(jsContext: context)
        JSFetch.shared.registerInto(jsContext: context)
    }

    /// Respond to an (AuroraEditor) JavaScript function.
    ///
    /// - Parameter action: action to perform
    /// - Parameter parameters: with parameters
    /// 
    /// - Returns: response value from javascript
    func respond(action: String, parameters: [String: Any]) -> JSValue? {
        return context
            .objectForKeyedSubscript(action)?
            .call(withArguments: Array(parameters.values).compactMap { val in
                // Custom view models can crash, only return their name.
                // The problem is that it is inerhited from Codable so
                // as? Codable will always pass, so we need to check this
                // on the first possible position.
                if let newVal = val as? ExtensionCustomViewModel {
                    return newVal.name as Any
                }

                // It confirms to Codable, that _should_ be safe
                if val as? Codable != nil {
                    return val // We want the "Any" returned.
                }

                // This is probably unsafe, do not return.
                return nil
            })
    }

    /// Respond to an (AuroraEditor) JavaScript function.
    /// 
    /// - Parameter action: action to perform
    /// - Parameter parameters: with parameters
    /// 
    /// - Returns: response value from javascript
    func respondToAE(action: String, parameters: [String: Any]) -> JSValue? {
        return context
            .objectForKeyedSubscript("AuroraEditor")?
            .objectForKeyedSubscript(action)?
            .call(withArguments: Array(parameters.values))
    }

    /// Evaluate a script on the current context
    /// 
    /// - Parameter script: script to evaluate
    /// 
    /// - Returns: the JS Value
    func evaluate(script: String) -> JSValue? {
        return context
            .evaluateScript(script)
    }

    // MARK: - Aurora Editor Extension interface
    /// Respond to an (AuroraEditor) JavaScript function.
    /// 
    /// - Parameter action: action to perform
    /// - Parameter parameters: with parameters
    /// 
    /// - Returns: response value from javascript
    func respond(action: String, parameters: [String: Any]) -> Bool {
        if let val = self.respond(action: action, parameters: parameters), val.isBoolean {
            return val.toBool()
        }

        return true
    }

    /// Register JSSupport as an extension
    func register() -> AEExtensionKit.ExtensionManifest {
        return .init(
            name: extensionName,
            displayName: extensionName,
            version: "1.0.0",
            minAEVersion: "0.0.1"
        )
    }
}
