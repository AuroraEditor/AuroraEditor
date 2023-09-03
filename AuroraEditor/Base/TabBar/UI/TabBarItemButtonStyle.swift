//
//  TabBarItemButtonStyle.swift
//  Aurora Editor
//
//  Created by Khan Winter on 6/4/22.
//  Copyright © 2023 Aurora Company. All rights reserved.
//
//  This file originates from CodeEdit, https://github.com/CodeEditApp/CodeEdit

import SwiftUI

struct TabBarItemButtonStyle: ButtonStyle {
    @Environment(\.colorScheme)
    var colorScheme

    @StateObject
    private var prefs: AppPreferencesModel = .shared

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .background(
                configuration.isPressed && prefs.preferences.general.tabBarStyle == .xcode
                ? (colorScheme == .dark ? .white.opacity(0.08) : .black.opacity(0.09))
                : .clear
            )
    }
}
