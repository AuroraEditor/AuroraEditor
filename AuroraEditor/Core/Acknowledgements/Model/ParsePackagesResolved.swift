//
//  ParsePackagesResolved.swift
//  Aurora Editor
//
//  Created by Shivesh M M on 4/4/22.
//  Copyright © 2023 Aurora Company. All rights reserved.
//

import Foundation

/// A struct to represent a dependency
struct Dependency: Decodable {
    /// The name of the dependency
    var name: String

    /// The link to the repository of the dependency
    var repositoryLink: String

    /// The version of the dependency
    var version: String

    /// The URL to the repository of the dependency
    var repositoryURL: URL {
        guard let url = URL(string: repositoryLink) else {
            fatalError("We can't find the URL of the repository")
        }

        return url
    }
}

/// A struct to represent the root object
struct RootObject: Codable {
    /// The object
    let object: Object
}

/// A struct to represent the object
struct Object: Codable {
    /// The pins
    let pins: [Pin]
}

/// A struct to represent the pin
struct Pin: Codable {
    /// The package name
    let package: String
    /// The repository URL
    let repositoryURL: String
    /// The state
    let state: AcknowledgementsState
}

/// A struct to represent the acknowledgements state
struct AcknowledgementsState: Codable {
    /// The revision
    let revision: String

    /// The version
    let version: String?
}
