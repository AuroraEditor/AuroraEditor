//
//  Response.swift
//  Aurora Editor
//
//  Created by Pavel Kasila on 5.04.22.
//

import Foundation

/// Response
public struct Response<T> {
    /// Value
    public let value: T
    /// URL Response
    public let response: URLResponse
}
