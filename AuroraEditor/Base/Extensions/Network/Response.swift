//
//  Response.swift
//  Aurora Editor
//
//  Created by Pavel Kasila on 5.04.22.
//  Copyright © 2023 Aurora Company. All rights reserved.
//
//  This file originates from CodeEdit, https://github.com/CodeEditApp/CodeEdit

import Foundation

/// Response
public struct Response<T> {
    /// Value
    public let value: T
    /// URL Response
    public let response: URLResponse
}
