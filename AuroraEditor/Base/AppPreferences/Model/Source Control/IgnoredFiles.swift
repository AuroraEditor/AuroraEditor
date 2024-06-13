//
//  IgnoredFiles.swift
//  Aurora Editor
//
//  Created by Nanashi Li on 2022/04/08.
//  Copyright © 2023 Aurora Company. All rights reserved.
//

import Foundation

/// A struct to represent ignored files
public struct IgnoredFiles: Codable, Identifiable, Hashable {
    /// The unique identifier for the ignored file
    public var id: String

    /// The name of the ignored file
    public var name: String
}
