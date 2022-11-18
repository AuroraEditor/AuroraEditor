//
//  BindingProxy.swift
//  AuroraEditor
//
//  Created by Wesley de Groot on 18/11/2022.
//  Copyright © 2022 Aurora Company. All rights reserved.
//

import SwiftUI

public extension Binding where Value: Equatable {
    static func proxy(_ source: Binding<Value>) -> Binding<Value> {
            self.init(
                get: { source.wrappedValue },
                set: { source.wrappedValue = $0 }
            )
    }
}
