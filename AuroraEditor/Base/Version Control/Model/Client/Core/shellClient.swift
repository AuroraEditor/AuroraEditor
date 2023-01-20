//
//  shellClient.swift
//  Aurora Editor
//
//  Created by Wesley de Groot on 22/07/2022.
//

import Foundation

/// Shared shell client
public var sharedShellClient: World = .init()

// Inspired by: https://vimeo.com/291588126
/// World. (not used?)
public struct World {
    var shellClient: ShellClient = .live()
}
