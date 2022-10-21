//
//  ScopeName.swift
//  
//
//  Created by Matthew Davidson on 31/12/19.
//

import Foundation

public class ScopeName: RawRepresentable {

    public let rawValue: String
    public let components: [String]

    public required init(rawValue: String) {
        self.rawValue = rawValue
        self.components = rawValue.split(separator: ".").map(String.init)
    }
}
