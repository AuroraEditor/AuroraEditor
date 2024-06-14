//
//  StatusBarTabType.swift
//  Aurora Editor
//
//  Created by Lukas Pistrol on 11.05.22.
//  Copyright © 2023 Aurora Company. All rights reserved.
//

import Foundation

/// A collection of types describing possible tabs in the Status Bar.
public enum StatusBarTabType: String, CaseIterable, Identifiable {
    /// The terminal tab.
    case terminal

    /// The debugger tab.
    case debugger

    /// The output tab.
    case output

    /// The id of the tab.
    public var id: String { self.rawValue }

    /// All tab options.
    public static var allOptions: [String] {
        StatusBarTabType.allCases.map(\.rawValue.capitalized)
    }
}
