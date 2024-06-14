//
//  PluginRelease.swift
//  Aurora Editor
//
//  Created by Pavel Kasila on 5.04.22.
//  Copyright © 2023 Aurora Company. All rights reserved.
//

import Foundation

/// Plugin Release
public struct PluginRelease: Codable, Hashable, Identifiable {
    /// Unique identifier of the plugin release.
    public var id: UUID

    /// Extension External ID
    public var externalID: String

    /// Extension Version
    public var version: String

    /// Extension tarball
    public var tarball: URL?
}
