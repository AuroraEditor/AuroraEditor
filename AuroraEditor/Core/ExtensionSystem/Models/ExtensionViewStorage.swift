//
//  ExtensionViewStorage.swift
//  Aurora Editor
//
//  Created by Wesley de Groot on 11/04/2024.
//  Copyright © 2024 Aurora Company. All rights reserved.
//

import Foundation

/// Extension view storage
/// This class stores the views used by extensions
class ExtensionViewStorage {
    /// Shared instance for Extension View Storage
    @MainActor
    public static let shared: ExtensionViewStorage = .init()

    /// Extension View Storage (DO NOT MODIFY DIRECTLY)
    public var storage: [UUID: Any] = [:]
}
