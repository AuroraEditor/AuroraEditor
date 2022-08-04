//
//  shellClient.swift
//  AuroraEditor
//
//  Created by Wesley de Groot on 22/07/2022.
//

import Foundation

public var sharedShellClient: World = .init()

// Inspired by: https://vimeo.com/291588126
public struct World {
    var shellClient: ShellClient = .live()
}
