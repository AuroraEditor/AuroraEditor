//
//  ExtensionManifest.swift
//  
//
//  Created by Pavel Kasila on 27.03.22.
//

import Foundation

public struct ExtensionManifest: Codable, Hashable {
    public var name: String
    public var displayName: String
    public var homepage: URL?
    public var repository: URL?
    public var issues: URL?
}
