//
//  Page.swift
//  Aurora Editor
//
//  Created by Pavel Kasila on 5.04.22.
//  Copyright © 2023 Aurora Company. All rights reserved.
//

import Foundation

/// Page
public struct Page<T: Codable>: Codable {
    /// Items
    public var items: [T]

    /// Metadata
    public var metadata: Metadata

    /// Metadata
    public struct Metadata: Codable {
        /// Total items
        public var total: Int

        /// Items per page
        public var per: Int

        /// Current page
        public var page: Int
    }
}
