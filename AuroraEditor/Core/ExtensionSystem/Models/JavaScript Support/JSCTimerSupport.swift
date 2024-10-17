//
//  JSTimerSupport.swift
//  Aurora Editor
//
//  Created by Wesley de Groot on 11/04/2024.
//  Copyright © 2024 Aurora Company. All rights reserved.
//

import Foundation
@preconcurrency import JavaScriptCore

/// JavaScript timer support
///
/// Supported timer functions:
/// - `setTimeout(callback, time)`
/// - `clearTimeout(identifier)`
/// - `setInterval(callback, time)`
@objc protocol AEJSTimer: JSExport {
    /// JavaScript `setTimeout` function
    /// 
    /// - Parameters:
    ///   - callback: Callback
    ///   - time: Time to wait
    /// 
    /// - Returns: Unique identifier to cancel task
    func setTimeout(_ callback: JSValue, _ time: Double) -> String

    /// JavaScript `clearTimeout` function
    /// 
    /// - Parameter identifier: The identifier to cancel (see the result of the timer)
    func clearTimeout(_ identifier: String)

    /// JavaScript `setInterval` function
    /// 
    /// - Parameters:
    ///   - callback: Callback
    ///   - time: Time to wait
    /// 
    /// - Returns: Unique identifier to cancel task
    func setInterval(_ callback: JSValue, _ time: Double) -> String
}

/// JavaScript timer support
///
/// Supported timer functions:
/// - `setTimeout(callback, time)`
/// - `clearTimeout(identifier)`
/// - `setInterval(callback, time)`
@objc
class JSCTimerSupport: NSObject, AEJSTimer {

    /// Shared instance of `JSCTimerSupport`.
    nonisolated(unsafe) static let shared: JSCTimerSupport = .init()

    /// Storage for the timers
    var timers = [String: Timer]()

    /// Register class into the current JavaScript Context.
    /// - Parameter jsContext: The current JavaScript context.
    func registerInto(jsContext: JSContext) {
        jsContext.setObject(
            JSCTimerSupport.shared,
            forKeyedSubscript: "AETimer" as (NSCopying & NSObjectProtocol)
        )

        jsContext.evaluateScript("""
            function setTimeout(callback, ms) { return AETimer.setTimeout(callback, ms) }
            function clearTimeout(indentifier) { AETimer.clearTimeout(indentifier) }
            function setInterval(callback, ms) { return AETimer.setInterval(callback, ms) }
        """)
    }

    /// JavaScript `clearTimeout` function
    /// 
    /// - Parameter identifier: The identifier to cancel (see the result of the timer)
    func clearTimeout(_ identifier: String) {
        let timer = timers.removeValue(forKey: identifier)

        timer?.invalidate()
    }

    /// JavaScript `setInterval` function
    /// 
    /// - Parameter callback: Callback
    /// - Parameter time: Time to wait
    func setInterval(_ callback: JSValue, _ time: Double) -> String {
        return createTimer(callback: callback, time: time, repeats: true)
    }

    /// JavaScript `setTimeout` function
    /// 
    /// - Parameters:
    ///   - callback: Callback
    ///   - time: Time to wait
    /// 
    /// - Returns: Unique identifier to cancel task
    func setTimeout(_ callback: JSValue, _ time: Double) -> String {
        return createTimer(callback: callback, time: time, repeats: false)
    }

    /// (Internal) Create a timer
    /// 
    /// - Parameters:
    ///   - callback: fallback
    ///   - time: time
    ///   - repeats: repeats?
    /// 
    /// - Returns: Unique identifier to cancel task.
    func createTimer(callback: JSValue, time: Double, repeats: Bool) -> String {
        let timeInterval = time / 1000.0

        let uuid = NSUUID().uuidString

        DispatchQueue.main.async(execute: {
            let timer = Timer.scheduledTimer(
                timeInterval: timeInterval,
                target: self,
                selector: #selector(self.callJsCallback),
                userInfo: callback,
                repeats: repeats
            )

            self.timers[uuid] = timer
        })

        return uuid
    }

    /// Call JavaScript callback
    /// 
    /// - Parameter timer: for which timer
    @objc func callJsCallback(_ timer: Timer) {
        if let callback = timer.userInfo as? JSValue {
            callback.call(withArguments: nil)
        }
    }
}
