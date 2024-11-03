//
//  AuroraCrashlytics.swift
//  Aurora Editor
//
//  Created by Nanashi Li on 2022/07/30.
//  Copyright © 2023 Aurora Company. All rights reserved.
//

import Foundation
import AppKit

// This is a very basic implementation of handling crashes/bugs in live production
// of Aurora Editor. This will end up being a more complex crashlytics in the future.
public protocol AuroraCrashlyticsDelegate: NSObjectProtocol {
    func auroraCrashlyticsDidCatchCrash(with model: CrashModel)
}

/// A weak wrapper for AuroraCrashlyticsDelegate
class WeakAuroraCrashlyticsDelegate: NSObject {
    /// The weak delegate
    weak var delegate: AuroraCrashlyticsDelegate?

    /// Weak wrapper for AuroraCrashlyticsDelegate
    /// 
    /// - Parameter delegate: The delegate to wrap
    init(delegate: AuroraCrashlyticsDelegate) {
        super.init()
        self.delegate = delegate
    }
}

/// The type of crash
public enum CrashModelType: Int {
    /// Signal
    case signal = 1

    /// Exception
    case exception = 2
}

/// The crash model
open class CrashModel: NSObject {
    /// The type of crash
    open var type: CrashModelType

    /// The name of the crash
    open var name: String

    /// The reason of the crash
    open var reason: String

    /// The app info
    open var appinfo: String

    /// The call stack
    open var callStack: String

    /// Creates a new instance of the crash model
    /// 
    /// - Parameter type: The type of crash
    /// - Parameter name: The name of the crash
    /// - Parameter reason: The reason of the crash
    /// - Parameter appinfo: The app info
    /// - Parameter callStack: The call stack
    init(type: CrashModelType,
         name: String,
         reason: String,
         appinfo: String,
         callStack: String) {
        self.type = type
        self.name = name
        self.reason = reason
        self.appinfo = appinfo
        self.callStack = callStack
    }
}

/// The old exception handler
nonisolated(unsafe) private var appOldExceptionHandler: (@convention(c) (NSException) -> Swift.Void)?

/// The crashlytics
@MainActor
public class AuroraCrashlytics: NSObject {
    /// A boolean value indicating whether the crashlytics is open
    public private(set) static var isOpen: Bool = false

    /// Adds a delegate
    /// 
    /// - Parameter delegate: The delegate
    open class func add(delegate: AuroraCrashlyticsDelegate) {
        // delete null week delegate
        self.delegates = self.delegates.filter {
            return $0.delegate != nil
        }

        // judge if contains the delegate from parameter
        let contains = self.delegates.contains {
            return $0.delegate?.hash == delegate.hash
        }
        // if not contains, append it with weak wrapped
        if contains == false {
            let week = WeakAuroraCrashlyticsDelegate(delegate: delegate)
            self.delegates.append(week)
        }

        if !self.delegates.isEmpty {
            self.open()
        }
    }

    /// Removes a delegate
    /// 
    /// - Parameter delegate: The delegate
    open class func remove(delegate: AuroraCrashlyticsDelegate) {
        self.delegates = self.delegates.filter {
            // filter null weak delegate
            return $0.delegate != nil
        }.filter {
                // filter the delegate from parameter
                return $0.delegate?.hash != delegate.hash
        }

        if self.delegates.isEmpty {
            self.close()
        }
    }

    /// Opens the crashlytics
    private class func open() {
        guard self.isOpen == false else {
            return
        }
        AuroraCrashlytics.isOpen = true

        appOldExceptionHandler = NSGetUncaughtExceptionHandler()
        NSSetUncaughtExceptionHandler(AuroraCrashlytics.RecieveException)
        self.setCrashSignalHandler()
    }

    /// Closes the crashlytics
    private class func close() {
        guard self.isOpen == true else {
            return
        }
        AuroraCrashlytics.isOpen = false
        NSSetUncaughtExceptionHandler(appOldExceptionHandler)
    }

    /// Sets the crash signal handler
    private class func setCrashSignalHandler() {
        signal(SIGABRT, AuroraCrashlytics.RecieveSignal)
        signal(SIGILL, AuroraCrashlytics.RecieveSignal)
        signal(SIGSEGV, AuroraCrashlytics.RecieveSignal)
        signal(SIGFPE, AuroraCrashlytics.RecieveSignal)
        signal(SIGBUS, AuroraCrashlytics.RecieveSignal)
        signal(SIGPIPE, AuroraCrashlytics.RecieveSignal)
        signal(SIGTRAP, AuroraCrashlytics.RecieveSignal)
    }

    /// The new exception handler
    private static let RecieveException: @convention(c) (NSException) -> Swift.Void = { (exteption) -> Void in
        // swiftlint:disable:previous redundant_void_return
        if appOldExceptionHandler != nil {
            if let appOldExceptionHandler = appOldExceptionHandler {
                appOldExceptionHandler(exteption)
            }
        }

        guard AuroraCrashlytics.isOpen == true else {
            return
        }

        let callStack = exteption.callStackSymbols.joined(separator: "\r")
        let reason = exteption.reason ?? ""
        let name = exteption.name
        let appinfo = AuroraCrashlytics.appInfo()
        let model = CrashModel(type: CrashModelType.exception,
                               name: name.rawValue,
                               reason: reason,
                               appinfo: appinfo,
                               callStack: callStack)
        for delegate in AuroraCrashlytics.delegates {
            delegate.delegate?.auroraCrashlyticsDidCatchCrash(with: model)
        }
    }

    /// The signal handler
    private static let RecieveSignal: @convention(c) (Int32) -> Void = { (signal) -> Void in
        // swiftlint:disable:previous redundant_void_return
        guard AuroraCrashlytics.isOpen == true else {
            return
        }

        var stack = Thread.callStackSymbols
        stack.removeFirst(2)
        let callStack = stack.joined(separator: "\r")
        let reason = "Signal \(AuroraCrashlytics.name(of: signal))(\(signal)) was raised.\n"
        let appinfo = AuroraCrashlytics.appInfo()

        let model = CrashModel(type: CrashModelType.signal,
                               name: AuroraCrashlytics.name(of: signal),
                               reason: reason,
                               appinfo: appinfo,
                               callStack: callStack)

        for delegate in AuroraCrashlytics.delegates {
            delegate.delegate?.auroraCrashlyticsDidCatchCrash(with: model)
        }

        AuroraCrashlytics.killApp()
    }

    /// App info
    /// 
    /// - Returns: The app info
    private class func appInfo() -> String {
        let displayName = Bundle.main.object(forInfoDictionaryKey: "CFBundleName") ?? ""
        let shortVersion = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") ?? ""
        let version = Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") ?? ""
        let deviceModel = Host.current().localizedName
        let systemVersion = ProcessInfo().operatingSystemVersion
        return "App: \(displayName) \(shortVersion)(\(version))\n" +
        "Device:\(deviceModel ?? "Unknown device")\n" + "OS Version:\(systemVersion)"
    }

    /// The name of the signal
    /// 
    /// - Parameter signal: The signal
    private class func name(of signal: Int32) -> String {
        switch signal {
        case SIGABRT:
            return "SIGABRT"
        case SIGILL:
            return "SIGILL"
        case SIGSEGV:
            return "SIGSEGV"
        case SIGFPE:
            return "SIGFPE"
        case SIGBUS:
            return "SIGBUS"
        case SIGPIPE:
            return "SIGPIPE"
        default:
            return "OTHER"
        }
    }

    /// Kills the app
    private class func killApp() {
        NSSetUncaughtExceptionHandler(nil)

        signal(SIGABRT, SIG_DFL)
        signal(SIGILL, SIG_DFL)
        signal(SIGSEGV, SIG_DFL)
        signal(SIGFPE, SIG_DFL)
        signal(SIGBUS, SIG_DFL)
        signal(SIGPIPE, SIG_DFL)

        kill(getpid(), SIGKILL)
    }

    /// The delegates
    fileprivate static var delegates = [WeakAuroraCrashlyticsDelegate]()
}
