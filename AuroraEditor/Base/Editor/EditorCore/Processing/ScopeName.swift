//
//  ScopeName.swift
//  Aurora Editor
//
//  Created by Matthew Davidson on 31/12/19.
//  Copyright © 2023 Aurora Company. All rights reserved.
//

import Foundation

/// Scope name.
@available(*, deprecated)
public class ScopeName: RawRepresentable {
    /// The raw value of the scope name.
    public let rawValue: String

    /// The components of the scope name.
    public let components: [String]

    /// Initialize ScopeName
    /// 
    /// - Parameter rawValue: Raw value
    public required init(rawValue: String) {
        self.rawValue = rawValue
        self.components = rawValue.split(separator: ".").map(String.init)
    }
}
