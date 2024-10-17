//
//  JSPromise.swift
//  Aurora Editor
//
//  Created by Wesley de Groot on 04/06/2024.
//  Copyright © 2024 Aurora Company. All rights reserved.
//

import JavaScriptCore

@objc protocol JSPromiseExports: JSExport {
    /// JavaScript `then` function
    /// - Parameter resolve: callback to resolve
    /// - Returns: promise
    func then(_ resolve: JSValue) -> JSCPromise?

    /// JavaScript `catch` function
    /// - Parameter resolve: callback to resolve
    /// - Returns: promise
    func `catch`(_ reject: JSValue) -> JSCPromise?
}

/// JavaScript Promise support
class JSCPromise: NSObject, JSPromiseExports {
    /// Shared instance so it will not be unloaded.
    nonisolated(unsafe) static let shared: JSCPromise = .init()

    /// Resolve callback
    var resolve: JSValue?

    /// Reject callback
    var reject: JSValue?

    /// Next promise
    var next: JSCPromise?

    /// Timer
    var timer: Timer?

    /// Register class into the current JavaScript Context.
    /// - Parameter jsContext: The current JavaScript context.
    func registerInto(jsContext: JSContext) {
        jsContext.setObject(
            JSCPromise.self,
            forKeyedSubscript: "Promise" as (NSCopying & NSObjectProtocol)
        )

        jsContext.evaluateScript("""
            Error.prototype.isError = () => { return true }
        """)
    }

    func then(_ resolve: JSValue) -> JSCPromise? {
        // Setup the resolver (callback)
        self.resolve = resolve

        // Create another JSPromise
        self.next = JSCPromise()

        // Set the timer to 1s
        self.timer?.fireDate = Date(timeInterval: 1, since: Date())

        // Set up the timer
        self.next?.timer = self.timer

        // Unset the current timer
        self.timer = nil

        // Return the real promise
        return self.next
    }

    func `catch`(_ reject: JSValue) -> JSCPromise? {
        // Setup the reject (callback)
        self.reject = reject

        // Create another JSPromise
        self.next = JSCPromise()

        // Set the timer to 1s
        self.timer?.fireDate = Date(timeInterval: 1, since: Date())

        // Set up the timer
        self.next?.timer = self.timer

        // Unset the current timer
        self.timer = nil

        // Return the real promise
        return self.next
    }

    /// (internal) Promise did fail, calling reject
    /// - Parameter error: Error message to send to "catch"
    func fail(error: String) {
        // Check if we have a reject (`catch`).
        if let reject = reject {
            reject.call(withArguments: [error])
        } else if let next = next {
            next.fail(error: error)
        }
    }

    /// (internal) Call succeeded.
    /// - Parameter value: Send the success message to "then".
    func success(value: Any?) {
        // Check if we have a resolve (`then`).
        guard let resolve = resolve else { return }

        // Result
        var result: JSValue?

        // If we can unwrap the value
        if let value = value {
            // Callback with arguments
            result = resolve.call(withArguments: [value])
        } else {
            // Callback without arguments
            result = resolve.call(withArguments: [])
        }

        // Check if we have another Promise.
        guard let next = next else { return }

        // Can we unwrap the results of the last callback?
        if let result = result {
            // And it is not undefined
            if result.isUndefined {
                // Call the next `then`.
                next.success(value: nil)
                return
            } else if result.hasProperty("isError") {
                // Call the next `catch`.
                next.fail(error: result.toString())
                return
            }
        }

        // Call the next `then` if there is any.
        next.success(value: result)
    }
}
