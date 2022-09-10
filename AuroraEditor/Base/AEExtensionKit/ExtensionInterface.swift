//
//  ExtensionInterface.swift
//  
//
//  Created by Pavel Kasila on 27.03.22.
//

import Foundation

/// A protocol for extensions to conform to
public protocol ExtensionInterface {
}

open class ExtensionBuilder: NSObject {
    override public required init() {
        super.init()
    }

    /// Builds extension with API
    /// - Parameter withAPI: the API implementation itself
    open func build(withAPI api: ExtensionAPI) -> ExtensionInterface {
        fatalError("You should override ExtensionBuilder.build")
    }
}
