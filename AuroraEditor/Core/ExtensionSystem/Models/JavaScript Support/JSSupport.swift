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
    var context = JSContext()

    /// Responder (typealias because of cleaner code)
    typealias Responder = @convention (block) (String, [String: Any]) -> Any

    /// Create a function which returns "AEContext", it should be start witht the semicolon because we
    /// do not know if the last line of the extension is a newline.
    /// if the result of the total evaluation is "AEContext", the extension did load correctly,
    /// if the result is any other than that then either the extension developer has a early return,
    /// or a syntax error.
    ///
    /// - Note: Default value `;function AEContext() { return \"AEContext\" };`
    let aeContextDidLoad = ";function AEContext() { return \"AEContext\" };"

    /// Extension name.
    var extensionName = ""

    /// Save the current Workspace Document
    var workspace: WorkspaceDocument?

    /// Initialize JavaScript Support for Aurora Editor
    ///
    /// This class initializes JavaScript Support for Aurora Editor, this class
    /// sets up a logger `com.auroraeditor.JSSupport`, the category
    /// will be the name of the extension (as given as parameter).
    /// Further it register extensions to the JavaScript Context, so that your extension can use
    /// JavaScript functions which are not supported by default, such as timers, promises, network requests.
    /// and many more for more JavaScript Context functions search on https://docs.auroraeditor.com
    /// for classes which start with `JSC` as ``JSCFetch``, ``JSCPromise``, ``JSCTimerSupport``
    ///
    /// - Parameter name: Extension name
    /// - Parameter workspace: Workspace document
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
        registerErrorHandler()
        registerScripts()
        registerFunctions()

        // Load the JS Extension, do NEVER return nil if we are running tests.
        if !loadJSExtension(path: path) && name != "AEXCTestCase" {
            return nil
        }
    }

    /// Register and Load a JavaScript Extension
    ///
    /// This functions tries to register the extension into Aurora Editor, it loads the extension, then it adds
    /// the value of `aeContextDidLoad` to check if the file is valid and doesn't cause any errors.
    /// If the file loaded, and ae context was able to return `AEContext` that means that the extension is
    /// loaded successfully and can be used.
    ///
    /// - Parameter script: extension path
    /// - Returns: True if is loaded
    public func loadJSExtension(path: String) -> Bool {
        do {
            // Read the contents of the file
            let content = try String(contentsOfFile: path)

            // Evaluate the script
            context?.evaluateScript(aeContextDidLoad + content)

            // Check if the extension has loaded correctly
            if let result = context?.objectForKeyedSubscript("AEContext").call(withArguments: nil),
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

    /// Register the exception handler for JS.
    /// We should show this for extension developers, so they can use
    /// `Console.app` to view JS Errors, use `com.auroraeditor.JSSupport` as subsystem
    /// and the category is your extension name.
    func registerErrorHandler() {
        context?.exceptionHandler = { _, exception in
            // Remove `TypeError: undefined is not an object` warnings,
            // Since they are triggered as well if a function doesnt return a value.
            if exception?.description == "TypeError: undefined is not an object" {
                return
            }

            self.jsLogger.error("JS Error: \(exception?.description ?? "Unknown error")")
        }
    }

    /// Register the required functions for the JS API.
    func registerFunctions() {
        let log: @convention (block) (String) -> Bool = { (message: String) in
            self.jsLogger.debug("JSAPI Message: \(message)")

            return true
        }

        let broadcaster: Responder = { (action: String, parameters: [String: Any]) in
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
        context?
            .objectForKeyedSubscript("AuroraEditor")
            .setObject(
                unsafeBitCast(log, to: AnyObject.self),
                forKeyedSubscript: "log" as (NSCopying & NSObjectProtocol)
            )

        // Create AuroraEditor.respond(...)
        context?
            .objectForKeyedSubscript("AuroraEditor")
            .setObject(
                unsafeBitCast(broadcaster, to: AnyObject.self),
                forKeyedSubscript: "respond" as (NSCopying & NSObjectProtocol)
            )

        // Create AuroraEditor.respondTo(...)
        context?
            .objectForKeyedSubscript("AuroraEditor")
            .setObject(
                unsafeBitCast(broadcaster, to: AnyObject.self),
                forKeyedSubscript: "respondTo" as (NSCopying & NSObjectProtocol)
            )
    }

    /// Register all JavaScript Context extensions.
    ///
    /// Register the required AuroraEditor class, and load all JavaScript Context extensions
    func registerScripts() {
        guard let context = context else {
            return
        }

        // Make sure AuroraEditor is defined.
        // This script will be filled with aliases and more.
        context
            .evaluateScript("var AuroraEditor = {};")

        JSCTimerSupport.shared.registerInto(jsContext: context)
        JSCPromise.shared.registerInto(jsContext: context)
        JSCFetch.shared.registerInto(jsContext: context)
    }

    /// Respond to an (AuroraEditor) JavaScript function.
    ///
    /// - Parameter action: action to perform
    /// - Parameter parameters: with parameters
    ///
    /// - Returns: response value from javascript
    func respondToAE(action: String, parameters: [String: Any]) -> JSValue? {
        return context?
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
        return context?
            .evaluateScript(script)
    }

    // MARK: - Array to JSON converter.

    /// (Any) Array to JSON converter
    /// - Parameter array: input array
    /// - Returns: JSON String
    func anyArrayToJSON(array: [String: Any]) -> String {
        // Open JSON string
        var json = "{"

        for (key, value) in array {
            if let boolValue = value as? Bool {
                // Value is a boolean, booleans should not be escaped
                json.append("\"\(key)\":\(boolValue ? "true" : "false"),")
            } else if let numbericValue = value as? (any Numeric) {
                // Value is numeric, numeric characters don't need to be escaped
                json.append("\"\(key)\":\(numbericValue),")
            } else if let stringValue = value as? String {
                if stringValue.isValidJSON {
                    // Value is JSON
                    json.append("\"\(key)\":\(stringValue),")
                } else {
                    // Value is a string
                    json.append("\"\(key)\":\"\(escape(JSON: stringValue))\",")
                }
            } else {
                // Value is an unknown type.
                jsLogger.fault("Could not recast \(key), type is: \(type(of: value))")
            }
        }

        // Remove last ,
        json.removeLast()

        // Close the JSON String
        json.append("}")

        return json
    }

    /// Escape string to become JSON Safe
    /// - Parameter JSON: Input JSON/String
    /// - Returns: Safe string
    func escape(JSON: String) -> String {
        return JSON
            // Escape any escape characters
            .replacingOccurrences(of: "\\", with: "\\\\")
            // Escape " to \"
            .replacingOccurrences(of: "\"", with: "\\\"")
            // Escape newline to \n
            .replacingOccurrences(of: "\n", with: "\\n")
            // Escape (carriage)return to \r
            .replacingOccurrences(of: "\r", with: "\\r")
            // Escape tabs to \t
            .replacingOccurrences(of: "\t", with: "\\t")
    }

    // MARK: - Aurora Editor Extension interface
    /// Send a action to an extension to respond to
    ///
    /// - Parameter action: action to perform
    /// - Parameter parameters: with parameters
    ///
    /// - Returns: Response value from the extension
    @discardableResult
    func respond(action: String, parameters: [String: Any]) -> Any {
        var JSONParameters = self.anyArrayToJSON(array: parameters)

        jsLogger.debug(
            "Calling function \(action), with \(JSONParameters)"
        )

        // Re ensure that the string is safe
        JSONParameters = escape(JSON: JSONParameters)

        // Constructor to run `function(parameters)`
        let action = """
            if (typeof \(action) === 'function') {
                \(action)(JSON.parse(\"\(JSONParameters)\"))
            }
            """

        guard let val = context?.evaluateScript(action) else {
            return false
        }

        if val.isBoolean {
            return val.toBool()
        }

        if val.isObject, let object = val.toObject() {
            return object
        }

        if val.isString, let string = val.toString() {
            return string
        }

        if val.isArray, let array = val.toArray() {
            return array
        }

        if val.isNumber, let number = val.toNumber() {
            return number
        }

        return false
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
