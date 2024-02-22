//
//  Log.swift
//  Aurora Editor
//
//  Created by Wesley de Groot on 22/02/2024.
//  Copyright © 2024 Aurora Company. All rights reserved.
//

import SwiftUI
import os

let Log = Logger( // swiftlint:disable:this identifier_name
    subsystem: "com.auroraeditor",
    category: "AuroraEditor"
)

extension View {
    func log(_ closure: () -> Void) -> some View {
        return self
    }
}
