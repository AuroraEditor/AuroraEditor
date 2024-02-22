//
//  PluginRelease.swift
//  Aurora Editor
//
//  Created by Pavel Kasila on 5.04.22.
//  Copyright © 2023 Aurora Company. All rights reserved.
//

import Foundation

public struct PluginRelease: Codable, Hashable, Identifiable {
    public var id: UUID
    public var externalID: String
    public var version: String
    public var tarball: URL?
}
