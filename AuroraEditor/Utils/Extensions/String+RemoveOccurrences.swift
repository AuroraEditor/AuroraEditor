//
//  String+RemoveOccurrences.swift
//  Aurora Editor
//
//  Created by Lukas Pistrol on 24.04.22.
//  Copyright © 2023 Aurora Company. All rights reserved.
//

import Foundation

public extension String {

    /// Removes all `new-line` characters in a `String`
    /// - Returns: A String
    func removingNewLines() -> String {
        self.replacingOccurrences(of: "\n", with: "")
    }

    /// Removes all `space` characters in a `String`
    /// - Returns: A String
    func removingSpaces() -> String {
        self.replacingOccurrences(of: " ", with: "")
    }
}
