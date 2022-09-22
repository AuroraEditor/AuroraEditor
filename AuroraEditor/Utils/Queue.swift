//
//  Queue.swift
//  AuroraEditor
//
//  Created by Nanashi Li on 2022/09/21.
//  Copyright © 2022 Aurora Company. All rights reserved.
//

import Foundation

private let queueSpecificKey = DispatchSpecificKey<NSObject>()

let globalMainQueue = Queue(queue: DispatchQueue.main, specialIsMainQueue: true)
let globalUserInteractiveQueue = Queue(queue: DispatchQueue.global(qos: .userInteractive),
                                               specialIsMainQueue: false)
let globalUserInitiatedQueue = Queue(queue: DispatchQueue.global(qos: .userInitiated),
                                             specialIsMainQueue: false)
let globalDefaultQueue = Queue(queue: DispatchQueue.global(qos: .default), specialIsMainQueue: false)
let globalBackgroundQueue = Queue(queue: DispatchQueue.global(qos: .background), specialIsMainQueue: false)

public final class Queue {
    private let nativeQueue: DispatchQueue
    private var specific = NSObject()
    private let specialIsMainQueue: Bool

    public var queue: DispatchQueue {
        return self.nativeQueue
    }

    public class func mainQueue() -> Queue {
        return globalMainQueue
    }

    public class func concurrentDefaultQueue() -> Queue {
        return globalDefaultQueue
    }

    public class func concurrentBackgroundQueue() -> Queue {
        return globalBackgroundQueue
    }

    public init(queue: DispatchQueue) {
        self.nativeQueue = queue
        self.specialIsMainQueue = false
    }

    fileprivate init(queue: DispatchQueue, specialIsMainQueue: Bool) {
        self.nativeQueue = queue
        self.specialIsMainQueue = specialIsMainQueue
    }

    public init(name: String? = nil, qos: DispatchQoS = .default) {
        self.nativeQueue = DispatchQueue(label: name ?? "", qos: qos)

        self.specialIsMainQueue = false

        self.nativeQueue.setSpecific(key: queueSpecificKey, value: self.specific)
    }

    public func isCurrent() -> Bool {
        if DispatchQueue.getSpecific(key: queueSpecificKey) === self.specific {
            return true
        } else if self.specialIsMainQueue && Thread.isMainThread {
            return true
        } else {
            return false
        }
    }

    public func async(_ function: @escaping () -> Void) {
        if self.isCurrent() {
            function()
        } else {
            self.nativeQueue.async(execute: function)
        }
    }

    public func sync(_ function: () -> Void) {
        if self.isCurrent() {
            function()
        } else {
            self.nativeQueue.sync(execute: function)
        }
    }

    public func justDispatch(_ function: @escaping () -> Void) {
        self.nativeQueue.async(execute: function)
    }

    public func justDispatchWithQoS(qos: DispatchQoS, _ function: @escaping () -> Void) {
        self.nativeQueue.async(group: nil, qos: qos, flags: [.enforceQoS], execute: function)
    }

    public func after(_ delay: Double, _ function: @escaping() -> Void) {
        let time: DispatchTime = DispatchTime.now() + delay
        self.nativeQueue.asyncAfter(deadline: time, execute: function)
    }
}
