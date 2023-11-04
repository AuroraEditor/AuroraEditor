//
//  PanelDivider.swift
//  Aurora Editor
//
//  Created by Austin Condiff on 5/10/22.
//  Copyright © 2023 Aurora Company. All rights reserved.
//
//  This file originates from CodeEdit, https://github.com/CodeEditApp/CodeEdit

import SwiftUI

public struct PanelDivider: View {
    @Environment(\.colorScheme)
    private var colorScheme

    public init() {}

    public var body: some View {
        Divider()
            .opacity(0)
            .overlay(
                Color(.black)
                    .opacity(colorScheme == .dark ? 0.65 : 0.13)
            )
    }
}
