//
//  Page.swift
//  Aurora Editor
//
//  Created by Pavel Kasila on 5.04.22.
//  Copyright © 2023 Aurora Company. All rights reserved.
//
//  This file originates from CodeEdit, https://github.com/CodeEditApp/CodeEdit

import Foundation

public struct Page<T: Codable>: Codable {
    public var items: [T]

    public var metadata: Metadata

    public struct Metadata: Codable {
        public var total: Int
        public var per: Int
        public var page: Int
    }
}
