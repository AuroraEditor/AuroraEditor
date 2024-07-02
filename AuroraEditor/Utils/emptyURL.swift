//
//  emptyURL.swift
//  Aurora Editor
//
//  Created by Wesley de Groot on 02/07/2024.
//  Copyright © 2024 Aurora Company. All rights reserved.
//

import Foundation

/// This is a empty url
///
/// Used for fallback for unwrapping optionals in a clean way
///
/// Example:
///
/// ```swift
/// openURL(
///     URL(string: "https://auroraeditor.com") ?? emptyURL
/// )
/// ```
public let emptyURL: URL = {
    guard let url = URL(string: "") else {
        fatalError("Failed to generate EmptyURL")
    }

    return url
}()
