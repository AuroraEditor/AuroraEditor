//
//  StatusBarTabType.swift
//  Aurora Editor
//
//  Created by Lukas Pistrol on 11.05.22.
//  Copyright © 2023 Aurora Company. All rights reserved.
//
//  This file originates from CodeEdit, https://github.com/CodeEditApp/CodeEdit

import Foundation

/// A collection of types describing possible tabs in the Status Bar.
public enum StatusBarTabType: String, CaseIterable, Identifiable {
    case terminal
    case debugger
    case output

    public var id: String { self.rawValue }
    public static var allOptions: [String] {
        StatusBarTabType.allCases.map(\.rawValue.capitalized)
    }
}
