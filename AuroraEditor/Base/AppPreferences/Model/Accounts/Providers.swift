//
//  Providers.swift
//  Aurora Editor
//
//  Created by Nanashi Li on 2022/04/08.
//  Copyright © 2023 Aurora Company. All rights reserved.
//

import Foundation

/// A struct to represent a provider
struct Providers: Identifiable, Hashable {
    /// The name of the provider
    let name: String

    /// The icon of the provider
    let icon: String

    /// The unique id of the provider
    let id: String
}
