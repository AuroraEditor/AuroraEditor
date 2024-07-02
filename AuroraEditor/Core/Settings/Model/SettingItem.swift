//
//  SettingItem.swift
//  Aurora Editor
//
//  Created by Nanashi Li on 2022/08/19.
//  Copyright © 2023 Aurora Company. All rights reserved.
//

import SwiftUI

/// The setting item
struct SettingItem: Identifiable {
    /// The id of the setting item
    let id = UUID().uuidString

    /// The name of the setting item
    let name: String

    /// The image of the setting item
    let image: NSImage?

    /// Color start
    let colorStart: Color

    /// Color end
    let colorEnd: Color
}
