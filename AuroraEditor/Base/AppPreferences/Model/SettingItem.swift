//
//  SettingItem.swift
//  AuroraEditor
//
//  Created by Nanashi Li on 2022/08/19.
//  Copyright © 2022 Aurora Company. All rights reserved.
//

import SwiftUI

struct SettingItem: Identifiable {
    let id = UUID().uuidString
    let name: String
    let image: NSImage
    let colour: Color
}
