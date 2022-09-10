//
//  TargetsAPI.swift
//  
//
//  Created by Pavel Kasila on 27.03.22.
//

import Foundation

/// API for targets
public protocol TargetsAPI {

    /// Adds new target to the list
    /// - Parameter target: the target to be added to the list
    func add(target: Target)

    /// Deletes a target from the list
    /// - Parameter target: the target to be removed from the list
    func delete(target: Target)

    /// Clears all targets from the list
    func clear()

}
