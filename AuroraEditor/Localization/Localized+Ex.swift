//
//  Localized+ex.swift
//  Aurora Editor
//
//  Created by Wesley de Groot on 20/01/2023.
//

import SwiftUI

extension String {
    func localized(_ custom: String? = nil) -> LocalizedStringKey {
        if let custom = custom {
            return LocalizedStringKey(custom)
        } else {
            return LocalizedStringKey(self)
        }
    }
}

extension LocalizedStringKey {
    static let helloWorld = "Hello, world!".localized()
}
