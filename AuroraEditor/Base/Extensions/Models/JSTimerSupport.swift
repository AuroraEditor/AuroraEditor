//
//  JSTimerSupport.swift
//  Aurora Editor
//
//  Created by Wesley de Groot on 11/04/2024.
//  Copyright © 2024 Aurora Company. All rights reserved.
//

import Foundation
import JavaScriptCore

@objc protocol AEJSTimer: JSExport {
    func setTimeout(_ callback: JSValue, _ time: Double) -> String
    func clearTimeout(_ identifier: String)
    func setInterval(_ callback: JSValue, _ time: Double) -> String
}

@objc class JSTimerSupport: NSObject, AEJSTimer {
    static let shared: JSTimerSupport = .init()
    var timers = [String: Timer]()

    func registerInto(jsContext: JSContext) {
        jsContext.setObject(
            JSTimerSupport.shared,
            forKeyedSubscript: "AETimer" as (NSCopying & NSObjectProtocol)
        )

        jsContext.evaluateScript("""
            function setTimeout(callback, ms) { return AETimer.setTimeout(callback, ms) }
            function clearTimeout(indentifier) { AETimer.clearTimeout(indentifier) }
            function setInterval(callback, ms) { return AETimer.setInterval(callback, ms) }
        """)
    }

    func clearTimeout(_ identifier: String) {
        let timer = timers.removeValue(forKey: identifier)

        timer?.invalidate()
    }

    func setInterval(_ callback: JSValue, _ time: Double) -> String {
        return createTimer(callback: callback, time: time, repeats: true)
    }

    func setTimeout(_ callback: JSValue, _ time: Double) -> String {
        return createTimer(callback: callback, time: time, repeats: false)
    }

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

    @objc func callJsCallback(_ timer: Timer) {
        if let callback = timer.userInfo as? JSValue {
            callback.call(withArguments: nil)
        }
    }
}
