//
//  BindingProxy.swift
//  Aurora Editor
//
//  Created by Wesley de Groot on 18/11/2022.
//  Copyright © 2023 Aurora Company. All rights reserved.
//

import SwiftUI

@available(*, deprecated, message: "Not used?")
public extension Binding where Value: Equatable {
    /// Returns a binding proxy.
    /// This proxyfies the binding, so you can use it in a `@StateObject` or `@ObservedObject`.\
    /// (while the original is unloaded)
    /// This should fix crashes in forEach loops, and Lists.
    /// 
    /// - Parameter source: The source binding.
    /// 
    /// - Returns: A binding proxy.
    @MainActor
    static func proxy(_ source: Binding<Value>) -> Binding<Value> {
            self.init(
                get: { source.wrappedValue },
                set: { source.wrappedValue = $0 }
            )
    }
}
